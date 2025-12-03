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

import argparse
import json
import os
import re
import subprocess
from swiftusd_ci_common import *

def install_cmake():
    print("Downloading CMake...")
    run(["curl", "-L", "https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-macos-universal.dmg",
        "--output", "CMake.dmg"],
        cwd=Environment.Path.tmp_dir, logOutput=False)

    print("Verifying SHA256 checksum...")
    # Hard-coded checksum taken from https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-SHA-256.txt,
    # cmake-3.28.6-macos-universal.dmg
    run(["shasum", "-a", "256", "-c"],
        input="d676ca7eb85be6d39c9c7595d858c3508b4076ed2ddb229a630c8ad0f22281dd *CMake.dmg",
        cwd=Environment.Path.tmp_dir)

    print("Attaching DMG...")
    run(["hdiutil", "attach", "CMake.dmg"], cwd=Environment.Path.tmp_dir, logOutput=False)

    print("Copying CMake.app to permanent location...")
    copy_src = "/Volumes/cmake-3.28.6-macos-universal/CMake.app/."
    copy_dest = Environment.Path.github_workspace / "../CMake.app"
    run(["cp", "-R", copy_src, copy_dest],
        cwd=Environment.Path.github_workspace, logOutput=False)

    print("Detaching DMG...")
    run(["hdiutil", "detach", "/Volumes/cmake-3.28.6-macos-universal"])

    env = os.environ.copy()
    env["PATH"] = str(copy_dest / "Contents" / "bin") + ":" + env["PATH"]

    print("Testing CMake is in PATH...")
    run(["which", "cmake"], env=env)

    return env

if __name__ == "__main__":
    env = install_cmake()
    clone_openusd(checkout=Environment.GitRef.openusd)
    print("Patching OpenUSD...")
    run(["git", "restore", "."], cwd=Environment.Path.openusd, logOutput=False)
    run(["git", "clean", "-fd"], cwd=Environment.Path.openusd, logOutput=False)
    run(["patch", "-p1", "-i", Environment.Path.swiftusd / "openusd-patch.patch"], cwd=Environment.Path.openusd, logOutput=False)
    print("Building OpenUSD...")
    run(["python3", "-u", "build_scripts/build_usd.py"] + get_openusd_build_flags(Environment.TestCombination.target_platform), env=env, cwd=Environment.Path.openusd)

