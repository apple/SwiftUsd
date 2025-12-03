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

if __name__ == "__main__":
    target_platforms = ["macOS", "iOSSimulator", "visionOSSimulator"]
    configs = ["Debug", "Release"]
    build_systems = ["xcodebuild-xcodeproj", "swiftbuild-SPM-Tests", "xcodebuild-SPM-Tests"]

    all_combinations = []
    for target_platform in target_platforms:
        for config in configs:
            for build_system in build_systems:

                # if target_platform == "macOS" and build_system == "xcodebuild-xcodeproj":
                #     # Disabled for now
                #     continue

                if build_system == "swiftbuild-SPM-Tests" and target_platform != "macOS":
                    # swiftbuild only supports macOS
                    continue

                all_combinations.append({"target_platform" : target_platform, "config" : config, "build_system" : build_system})

    random.shuffle(all_combinations)

    write(output=f"matrix={json.dumps(all_combinations)}")
    max_parallel = int(round(math.sqrt(len(all_combinations))))
    write(output=f"max-parallel={max_parallel}")

    printAndWrite(summary=collapsedSection(
        title=f"Will run {len(all_combinations)} test combinations with max-parallel={max_parallel}:",
        body=f"```\nmatrix={json.dumps(all_combinations, indent=2)}\n```"
    ))
