#===----------------------------------------------------------------------===#
# This source file is part of github.com/apple/SwiftUsd
#
# Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#===----------------------------------------------------------------------===#

from swiftusd_ci_common import *
import random
import json
import math

def get_xcodebuild_destination(target_platform):
    if target_platform == "macOS": return "platform=macOS,name=My Mac"
    elif target_platform == "iOS": return Environment.TestCombination.at_desk_iOS_xcodebuild_destination
    elif target_platform == "iOSSimulator": return "platform=iOS Simulator,name=iPhone 17 Pro"
    elif target_platform == "visionOS": return Environment.TestCombination.at_desk_visionOS_xcodebuild_destination
    elif target_platform == "visionOSSimulator": return "platform=visionOS Simulator,name=Apple Vision Pro"
    else:
        print(f"Error: Unknown target '{target_platform}'")
        exit(1)

def allCombinations(**kwargs):
    result = [{}]
    for (key, values) in kwargs.items():
        result = [x | {key : value} for value in values for x in result]

    result = [x | {"active_keys" : [], "incompatible_keys" : []} for x in result]
    return result

if __name__ == "__main__":
    toConsider = allCombinations(
        target_platform=["macOS", "iOS", "iOSSimulator", "visionOS", "visionOSSimulator"],
        config=["Debug", "Release"],
        build_system=["xcodebuild-xcodeproj", "swiftbuild-SPM-Tests", "xcodebuild-SPM-Tests"],
        toolchain_provider=getAllToolchainProviders()
    )

    result = []
    for x in toConsider:
        tc = x["toolchain_provider"]
        swiftly = parseSwiftlyToolchainProvider(tc)
        
        if x["build_system"] == "swiftbuild-SPM-Tests" and x["target_platform"] != "macOS":
            # swiftbuild only supports macOS
            continue

        if x["build_system"] == "xcodebuild-SPM-Tests" and x["target_platform"] in ["iOS", "visionOS"]:
            # xcodebuild on a Swift Package doesn't support physical iOS/visionOS devices
            continue

        
        if x["build_system"] == "xcodebuild-SPM-Tests":
            # xcodebuild on a Swift Package runs into `INTERNAL ERROR: Unable to load workspace`
            # before Xcode 26.0
            if swiftly == "xcode":
                version = getVersionOfToolchainProvider(tc)
                if isVersionLessThan(version, "26.0.0"):
                    continue

        if x["target_platform"] in ["visionOS", "visionOSSimulator"]:
            # visionOS/visionOSSimulator with swiftly 6.3.0/6.3.1 runs into build errors
            # using xcodebuild.
            #
            # - xcodebuild-xcodeproj runs into an error from a CoreMotion
            #   type having mismatched availability annotations
            # 
            # - xcodebuild-SPM-Tests runs into a linker error about
            #   libclang_rt.profile_xros.a/libclang_rt.profile_xrossim.a
            #   not being included as part of the toolchain.
            if swiftly.startswith("6.3."):
                if x["build_system"] in ["xcodebuild-xcodeproj", "xcodebuild-SPM-Tests"]:
                    continue

            # Similar linker errors through main-snapshot-2026-05-07 and likely further
            if swiftly.startswith("main-snapshot") and isVersionLessThanOrEqual(swiftly, "main-snapshot-2026-05-27"):
                if x["build_system"] in ["xcodebuild-xcodeproj", "xcodebuild-SPM-Tests"]:
                    continue

        if swiftly.startswith("6.2."):
            # Swiftly 6.2 runs into module deserialization failures from running up against
            # an arbitrary limit on the number of specializations of a class template
            # the compiler would create. This was fixed in Swiftly 6.3,
            # and only affects the OSS Swiftly toolchains, not Xcode toolchains.
            #
            # https://github.com/swiftlang/swift/pull/83751
            continue

        if swiftly.startswith("6.1."):
            # Swiftly 6.1 runs into various stack dumps with no clear workaround
            # besides using a newer compiler version
            continue
        
        if swiftly.startswith("main-snapshot") and isVersionLessThanOrEqual(swiftly, "main-snapshot-2026-05-27"):
            if x["build_system"] == "swiftbuild-SPM-Tests":
                # rdar://177175896 (swift build with main-snapshot-2026-05-07 not respecting CPLUS_INCLUDE_PATH; can't #include <swift/bridging> (regression))
                continue

        xcodebuild_destination = get_xcodebuild_destination(x["target_platform"])
        if xcodebuild_destination is None: continue
        x["xcodebuild_destination"] = xcodebuild_destination

        if x["target_platform"] in ["iOS", "visionOS"]:
            x["active_keys"].append(x["target_platform"])
            x["incompatible_keys"].append(x["target_platform"])

        result.append(x)

    random.shuffle(result)

    axes = {}
    for x in result:
        for k, v in x.items():
            if k == "active_keys" or k == "incompatible_keys": continue
            if k not in axes:
                axes[k] = []
            if v not in axes[k]:
                axes[k].append(v)

    axes = dict(sorted(axes.items()))
    for (k, v) in axes.items():
        axes[k] = sorted(v)

    write(output=f"matrix={json.dumps(result)}")
    max_parallel = int(round(math.sqrt(len(result))))
    write(output=f"max-parallel={max_parallel}")
    write(output=f"n-combinations={len(result)}")

    for (k, v) in axes.items():
        value_string = "\n".join(v)
        printAndWrite(summary=collapsedSection(
            title=f"`{k}` ({len(v)} variants)",
            body=f"```\n{value_string}\n```"
        ))

    printAndWrite(summary=collapsedSection(
        title=f"Will run {len(result)} test combinations with max-parallel={max_parallel}:",
        body=f"```\nmatrix={json.dumps(result, indent=2)}\n```"
    ))
