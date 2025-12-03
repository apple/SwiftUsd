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

from .environment import *
from .subprocesses import *

def openusd_build_dir(target): return str(Environment.Path.github_workspace / "openusd-builds" / target)

def clone_openusd(checkout=None):
    if not Environment.Path.openusd.exists():
        print("Cloning OpenUSD...")
        run(["git", "clone", "https://github.com/PixarAnimationStudios/OpenUSD.git", Environment.Path.openusd], logOutput=False)
    if checkout is not None:
        print(f"Checking out {checkout}")
        run(["git", "checkout", checkout], cwd=Environment.Path.openusd, logOutput=False)

def get_openusd_build_flags(target):
    if target == "macOS":
        return ["--embree", "--imageio", "--alembic", "--openvdb", "--no-python",
                "--ignore-homebrew", "--build-target", "native", openusd_build_dir("macOS")]

    if target == "iOS":
        return ["--imageio", "--alembic", "--no-python", "--ignore-homebrew",
                "--build-target", "iOS", openusd_build_dir("iOS")]

    if target == "iOSSimulator":
        return ["--imageio", "--alembic", "--no-python", "--ignore-homebrew",
                "--build-target", "iOSSimulator", openusd_build_dir("iOSSimulator")]

    if target == "visionOS":
        return ["--imageio", "--alembic", "--no-python", "--ignore-homebrew",
                "--build-target", "visionOS", openusd_build_dir("visionOS")]

    if target == "visionOSSimulator":
        return ["--imageio", "--alembic", "--no-python", "--ignore-homebrew",
                "--build-target", "visionOSSimulator", openusd_build_dir("visionOSSimulator")]

    raise ValueError(f"Unknown target {target}")