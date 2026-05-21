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
import platform
from swiftusd_ci_common import *

def build_or_run_test_suite(name, cleanCmd, resolveCmd, buildCmd, testCmd, resolveBuildTestCommonArgs, cwd, action, env=None):
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
            return any([s in l for s in ["error:", "DESERIALIZATION FAILURE", "Stack dump:", "While deserializing SIL function", "SIL verification failed", "Assertion failed:"]])
        elif action == "test":
            return any([s in l for s in ["failed:", "launchd", "crash", "exited with unexpected signal code", "skipped", "The test runner hung before establishing connection", "Early unexpected exit, operation never finished bootstrapping"]])

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

    resolveBuildTestCommonArgs = addConditionalCommonArgs(resolveBuildTestCommonArgs)

    if action == "build":
        print(f"Building {name} tests...")
        run(cleanCmd, cwd=cwd)
        if resolveCmd:
            run(resolveCmd + resolveBuildTestCommonArgs, cwd=cwd, env=env)
        processRunResult(run(buildCmd + resolveBuildTestCommonArgs, cwd=cwd, check=False, env=env))
        
        
    elif action == "test":
        print(f"Running {name} tests...")
        if resolveCmd:
            # Important! When using xcodebuild (on Xcode projects or Swift Packages)
            # with a custom Swift toolchain (`-toolchain foo`), Swift package resolution will fail
            # unless you explicitly resolve the package dependencies for the project/package
            # without the custom Swift toolchain active. However, it seems that a part
            # of package resolution is keyed to the **exact** set of environment values;
            # Adding, removing, or modifying _any_ environment variable between resolution
            # and the resulting `build-for-testing`/`test-without-building` will cause
            # package resolution to fail, even if you've requested xcodebuild to not
            # do any package resolution. When ci-at-desk is running the test suite locally,
            # it changes the GITHUB_STEP_SUMMARY and GITHUB_OUTPUT environment variables
            # between steps, and building and testing occur in different steps. Thus,
            # we have to do a resolve step before _both_ building and running, with
            # identical environment variables for each resolve and subsequent action.
            #
            # rdar://174939543 (Modifying a random (unused) environment variable causes `xcodebuild build -toolchain foo` to fail with an inscrutable posix_spawn message)
            run(resolveCmd + resolveBuildTestCommonArgs, cwd=cwd, env=env)
        processRunResult(run(testCmd + resolveBuildTestCommonArgs, cwd=cwd, check=False, env=env))

def prepare_to_build_tests():
    print("Preparing to build tests...")
    run(["swift", "package", "--package-path", "ReconfigurePbxprojPackageDependency", "clean"],
        cwd=Environment.Path.swiftusd_tests)
    run(["swift", "run", "--package-path", "ReconfigurePbxprojPackageDependency",
        "ReconfigurePbxprojPackageDependency", "SwiftUsdTests.xcodeproj/project.pbxproj",
         "--replace", "https://github.com/apple/SwiftUsd", "--with", "SwiftUsd"], 
        cwd=Environment.Path.swiftusd_tests)

    if (Environment.Path.swiftusd_tests / "SwiftUsd").exists():
        os.unlink(Environment.Path.swiftusd_tests / "SwiftUsd")
    (Environment.Path.swiftusd_tests / "SwiftUsd").symlink_to(Environment.Path.swiftusd)
    run(["python3", "make-spm-tests.py", "--local", "--force"],
        cwd=Environment.Path.swiftusd_tests)

def addConditionalCommonArgs(result):
    def handleBuildSystem(forXcodebuild):
        nonlocal result
        if forXcodebuild:
            index = [i for (i, x) in enumerate(result) if x.startswith("OTHER_SWIFT_FLAGS")][0]
            result[index] += " -DSWIFTUSD_TESTS_XCODEBUILD"
        else:
            result += ["-Xswiftc", "-DSWIFTUSD_TESTS_SWIFTBUILD"]
    
    def handleJobs(x, forXcodebuild):
        nonlocal result
        try:
            if int(x) > 0:
                result += ["-jobs" if forXcodebuild else "--jobs", x]
        except:
            pass        

    def handleDevelopmentTeam():
        nonlocal result
        if Environment.TestCombination.at_desk_development_team:
            result += [f"DEVELOPMENT_TEAM={Environment.TestCombination.at_desk_development_team}"]

    def handleSwiftly603x(forXcodebuild):
        nonlocal result
        swiftly = parseSwiftlyToolchainProvider()
        if swiftly.startswith("6.3."):
            if platform.system() == "Darwin":
                # Don't do this on Linux for now, I want to investigate these
                # crashes if they occur on Linux because they might be different there
                if forXcodebuild:
                    index = [i for (i, x) in enumerate(result) if x.startswith("OTHER_SWIFT_FLAGS")][0]
                    result[index] += " -DSWIFTUSD_TESTS_SKIP_SWIFTLY_603_CRASHES"
                else:
                    result += ["-Xswiftc", "-DSWIFTUSD_TESTS_SKIP_SWIFTLY_603_CRASHES"]

    def handleImportCxxMembersLazily(forXcodebuild):
        # Testing an experimental feature from https://github.com/swiftlang/swift/pull/87016.
        # For now, don't enable this by default, but make it easy to enable for one-off attempts
        return
        nonlocal result
        if forXcodebuild:
            index = [i for (i, x) in enumerate(result) if x.startswith("OTHER_SWIFT_FLAGS")][0]
            result[index] += " -enable-experimental-feature ImportCxxMembersLazily"
        else:
            result += ["-Xswiftc", "-enable-experimental-feature", "-Xswiftc", "ImportCxxMembersLazily"]

    if Environment.TestCombination.build_system == "xcodebuild-xcodeproj":
        handleJobs(Environment.TestCombination.at_desk_xcodebuild_jobs, True)
        handleDevelopmentTeam()
        handleSwiftly603x(True)
        handleBuildSystem(True)
        handleImportCxxMembersLazily(True)
        
    elif Environment.TestCombination.build_system == "swiftbuild-SPM-Tests":
        handleJobs(Environment.TestCombination.at_desk_swiftbuild_jobs, False)
        handleSwiftly603x(False)
        handleBuildSystem(False)
        handleImportCxxMembersLazily(False)
        
    elif Environment.TestCombination.build_system == "xcodebuild-SPM-Tests":
        handleJobs(Environment.TestCombination.at_desk_xcodebuild_jobs, True)
        handleDevelopmentTeam()
        handleSwiftly603x(True)
        handleBuildSystem(True)
        handleImportCxxMembersLazily(True)
        
    else:
        print(f"Error: Unknown build system {Environment.TestCombination.build_system}")
        exit(1)

    
    
    return result

def do_xcodebuild_xcodeproj_tests(action):
    build_or_run_test_suite(
        name="xcodebuild-xcodeproj",
        cleanCmd=["xcodebuild", "clean"],
        resolveCmd=["xcodebuild", "-resolvePackageDependencies"],
        buildCmd=[
            "xcodebuild", "build-for-testing",
            "-disableAutomaticPackageResolution", "-onlyUsePackageVersionsFromResolvedFile",
        ],
        testCmd=[
            "xcodebuild", "test-without-building",
             "-resultBundlePath", str(Environment.Path.result_bundle),
            "-disableAutomaticPackageResolution", "-onlyUsePackageVersionsFromResolvedFile",
        ],
        resolveBuildTestCommonArgs=[
            "-verbose", "-skipMacroValidation",
            "-scheme", "UnitTests",
            "-configuration", Environment.TestCombination.config,
            "-destination", Environment.TestCombination.xcodebuild_destination,
            "OTHER_SWIFT_FLAGS=$(inherited) -DSWIFTUSD_TESTS_SUPPRESS_PERFORMANCE_FAILURES",
            "-clonedSourcePackagesDirPath", "clonedSourcePackages",
        ],
        cwd=Environment.Path.swiftusd_tests,
        action=action,
    )

def do_swiftbuild_spm_tests(action):
    env = os.environ.copy()
    env["SWIFT_BACKTRACE"] = "interactive=no"

    # todo: revisit this, setting it here means that
    # xcodebuild -version in the logs is misleading because
    # it's computed without this environment variable
    if os.path.exists("/Applications/Xcode-latest.app"):
        # Set DEVELOPER_DIR to work around 
        # error: cannot load module 'SwiftCompilerPlugin' built with SDK 'macosx26.0' when using SDK 'macosx26.2'
        # https://github.com/apple/SwiftUsd/actions/runs/21256906902/job/61175337955
        env["DEVELOPER_DIR"] = "/Applications/Xcode-latest.app"

    build_or_run_test_suite(
        name="swiftbuild-SPM-Tests",
        cleanCmd=["swift", "package", "clean"],
        resolveCmd=None,
        buildCmd=["swift", "build", "--build-tests"],
        testCmd=["swift", "test", "--skip-build"],
        resolveBuildTestCommonArgs=[
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
        resolveCmd=["xcodebuild", "-resolvePackageDependencies"],
        buildCmd=[
            "xcodebuild", "build-for-testing",
            "-disableAutomaticPackageResolution", "-onlyUsePackageVersionsFromResolvedFile",
        ],
        testCmd=[
            "xcodebuild", "test-without-building",
             "-resultBundlePath", str(Environment.Path.result_bundle),
            "-disableAutomaticPackageResolution", "-onlyUsePackageVersionsFromResolvedFile",
        ],
        resolveBuildTestCommonArgs=[
            "-verbose", "-skipMacroValidation",
            "-scheme", "SPM-Tests-Package",
            "-config", Environment.TestCombination.config,
            "-destination", Environment.TestCombination.xcodebuild_destination,
            "OTHER_SWIFT_FLAGS=$(inherited) -DSWIFTUSD_TESTS_SUPPRESS_PERFORMANCE_FAILURES",
            "-clonedSourcePackagesDirPath", "clonedSourcePackages",            
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
    toolchainPrepareOnce()
    
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    build_tests(args=None, subparsers=subparsers)
    run_tests(args=None, subparsers=subparsers)

    args = parser.parse_args()

    args.func(args)
