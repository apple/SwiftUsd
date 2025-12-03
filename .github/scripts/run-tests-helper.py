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
import subprocess
import re
import pathlib
import shutil
import random
import time
from swiftusd_ci_common import *

def build_or_run_test_suite(name, cleanCmd, buildCmd, testCmd, buildTestCommonArgs, cwd, action, env=None):
    """Builds or runs the given test suite"""

    test_matrix_result = TestMatrixResult.load()
    test_matrix_result.action = action
    test_matrix_result.name = name
    test_matrix_result.returncode = -1
    test_matrix_result.setExtractedLinesToTimeout(action)
    test_matrix_result.write()

    start = time.time()

    def should_extract(l):
        if action == "build":
            return any([s in l for s in ["error:"]])
        elif action == "test":
            return any([s in l for s in ["failed:", "launchd"]])

    def processRunResult(runResult):
        end = time.time()
        actionAsVerb = "Building" if action == "build" else "Testing"

        test_matrix_result.returncode = runResult.returncode
        if action == "build":
            test_matrix_result.build_time = end - start
        else:
            test_matrix_result.test_time = end - start

        test_matrix_result.extracted_lines = []

        extractedLines = [l for l in runResult.output if should_extract(l)]
        test_matrix_result.extracted_lines = extractedLines

        test_matrix_result.write()

        exit(runResult.returncode)

    if action == "build":
        print(f"Building {name} tests...")
        run(cleanCmd, cwd=cwd)
        processRunResult(run(buildCmd + buildTestCommonArgs, cwd=cwd, check=False, env=env))
        
        
    elif action == "test":
        print(f"Running {name} tests...")
        processRunResult(run(testCmd + buildTestCommonArgs, cwd=cwd, check=False, env=env))

def prepare_to_build_tests():
    print("Preparing to build tests...")
    run(["swift", "run", "--package-path", "ReconfigurePbxprojPackageDependency",
        "ReconfigurePbxprojPackageDependency", "SwiftUsdTests.xcodeproj/project.pbxproj",
         "--replace", "https://github.com/apple/SwiftUsd", "--with", "SwiftUsd"], 
        cwd=Environment.Path.swiftusd_tests)
    if not (Environment.Path.swiftusd_tests / "SwiftUsd").exists():
        (Environment.Path.swiftusd_tests / "SwiftUsd").symlink_to(Environment.Path.swiftusd)
    run(["python3", "make-spm-tests.py", "--local", "--force"],
        cwd=Environment.Path.swiftusd_tests)

def get_xcodebuild_destination():
    if Environment.TestCombination.target_platform == "macOS": return "platform=macOS,name=My Mac"
    elif Environment.TestCombination.target_platform == "iOSSimulator": return "platform=iOS Simulator,name=iPhone 17 Pro"
    elif Environment.TestCombination.target_platform == "visionOSSimulator": return "platform=visionOS Simulator,name=Apple Vision Pro (at 2732x2048)"
    else:
        print(f"Error: Unknown target '{Environment.TestCombination.target_platform}'")
        exit(1)

def do_xcodebuild_xcodeproj_tests(action):
    build_or_run_test_suite(
        name="xcodebuild-xcodeproj",
        cleanCmd=["xcodebuild", "clean"],
        buildCmd=["xcodebuild", "build-for-testing"],
        testCmd=[
            "xcodebuild", "test-without-building",
             "-resultBundlePath", str(Environment.Path.result_bundle),
        ],
        buildTestCommonArgs=[
            "-verbose", "-skipMacroValidation",
            "-scheme", "UnitTests", 
            "-configuration", Environment.TestCombination.config,
            "-destination", get_xcodebuild_destination(),
            "OTHER_SWIFT_FLAGS=$(inherited) -DSWIFTUSD_TESTS_SUPPRESS_PERFORMANCE_FAILURES",
        ],
        cwd=Environment.Path.swiftusd_tests,
        action=action,
    )

def do_swiftbuild_spm_tests(action):
    env = os.environ.copy()
    env["SWIFT_BACKTRACE"] = "interactive=no"

    # Set DEVELOPER_DIR to work around 
    # error: cannot load module 'SwiftCompilerPlugin' built with SDK 'macosx26.0' when using SDK 'macosx26.2'
    # https://github.com/apple/SwiftUsd/actions/runs/21256906902/job/61175337955
    env["DEVELOPER_DIR"] = "/Applications/Xcode-latest.app"

    build_or_run_test_suite(
        name="swiftbuild-SPM-Tests",
        cleanCmd=["swift", "package", "clean"],
        buildCmd=["swift", "build", "--build-tests"],
        testCmd=["swift", "test", "--skip-build"],
        buildTestCommonArgs=[
            "-v",
            "-Xswiftc", "-DOPENUSD_SWIFT_BUILD_FROM_CLI", "-Xcxx", "-DOPENUSD_SWIFT_BUILD_FROM_CLI",
            "--configuration", Environment.TestCombination.config.lower(),
            "-Xswiftc", "-DSWIFTUSD_TESTS_SUPPRESS_PERFORMANCE_FAILURES",
        ],
        cwd=Environment.Path.swiftusd_tests / "SPM-Tests",
        action=action,
        env=env
    )

def do_xcodebuild_spm_tests(action):
    build_or_run_test_suite(
        name="xcodebuild-SPM-Tests",
        cleanCmd=["swift", "package", "clean"],
        buildCmd=["xcodebuild", "build-for-testing"],
        testCmd=[
            "xcodebuild", "test-without-building",
             "-resultBundlePath", str(Environment.Path.result_bundle)
        ],
        buildTestCommonArgs=[
            "-verbose", "-skipMacroValidation",
            "-scheme", "SPM-Tests-Package",
            "-config", Environment.TestCombination.config,
            "-destination", get_xcodebuild_destination(),
            "OTHER_SWIFT_FLAGS=$(inherited) -DSWIFTUSD_TESTS_SUPPRESS_PERFORMANCE_FAILURES",
        ],
        cwd=Environment.Path.swiftusd_tests / "SPM-Tests",
        action=action,
    )

def build_tests(args, subparsers):
    if subparsers is not None:
        parser = subparsers.add_parser("build-tests")
        parser.set_defaults(func=lambda args: build_tests(args=args, subparsers=None))
        return

    prepare_to_build_tests()
    if Environment.TestCombination.build_system == "xcodebuild-xcodeproj": do_xcodebuild_xcodeproj_tests(action="build")
    elif Environment.TestCombination.build_system == "swiftbuild-SPM-Tests": do_swiftbuild_spm_tests(action="build")
    elif Environment.TestCombination.build_system == "xcodebuild-SPM-Tests": do_xcodebuild_spm_tests(action="build")
    else:
        print(f"Error: Unknown build system {Environment.TestCombination.build_system}")
        exit(1)

def run_tests(args, subparsers):
    if subparsers is not None:
        parser = subparsers.add_parser("run-tests")
        parser.set_defaults(func=lambda args: run_tests(args=args, subparsers=None))
        return

    if Environment.TestCombination.build_system == "xcodebuild-xcodeproj": do_xcodebuild_xcodeproj_tests(action="test")
    elif Environment.TestCombination.build_system == "swiftbuild-SPM-Tests": do_swiftbuild_spm_tests(action="test")
    elif Environment.TestCombination.build_system == "xcodebuild-SPM-Tests": do_xcodebuild_spm_tests(action="test")
    else:
        print(f"Error: Unknown build system {Environment.TestCombination.build_system}")
        exit(1)
    
# MARK: Main

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    build_tests(args=None, subparsers=subparsers)
    run_tests(args=None, subparsers=subparsers)

    args = parser.parse_args()

    args.func(args)