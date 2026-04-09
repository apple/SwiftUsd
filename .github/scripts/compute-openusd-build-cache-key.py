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
import re

if __name__ == "__main__":
    openusd_patch_hash = run(["shasum", "-a", "256", "./openusd-patch.patch"], cwd=Environment.Path.swiftusd, logOutput=False).output[0]
    # extract the hash, dropping the file name
    openusd_patch_hash = re.search(r"([0-9a-f]+)", openusd_patch_hash).groups(1)[0]
    compiler_version = run(["swift", "--version"], logOutput=False).output[0]
    # extract `(swiftlang VERSION clang-VERSION)`, dropping the parentheses
    compiler_version = re.search(r"\((swiftlang.*)\)", compiler_version).groups(1)[0]
    host_version = run(["sw_vers", "--productVersion"], logOutput=False).output[0] + "(" + run(["sw_vers", "--buildVersion"], logOutput=False).output[0] + ")"
    # Turn branch names like `dev` into a hash commit to avoid incorrect cache key matches
    clone_openusd()
    rev_parsed_ref = run(["git", "rev-parse", Environment.GitRef.openusd], cwd=Environment.Path.openusd, logOutput=False).output[0]
    build_flags = get_openusd_build_flags(Environment.TestCombination.target_platform)
    # Don't include the build directory when forming the cache key
    build_flags = [x for x in build_flags if not x.startswith("/")]
    build_flags = "".join(build_flags)
    # Substitute out the source directory as well, for ci-at-desk
    build_flags = build_flags.replace(str(Environment.Path.openusd), "OPENUSD_SOURCE_DIR")

    result = "  ".join([
        Environment.TestCombination.target_platform,
        compiler_version,
        Environment.TestCombination.target_platform + host_version,
        build_flags,
        rev_parsed_ref,
        openusd_patch_hash
    ])

    # Cache keys cannot contain commas
    result = result.replace(",", "")
    printAndWrite(output=f"cache-key={result}")
