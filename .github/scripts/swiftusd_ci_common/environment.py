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

import os
import pathlib

def _getenvpath(k):
    result = os.getenv(k)
    if result is not None: result = pathlib.Path(result)
    return result

class Environment:
    class GitRef:
        swiftusd = os.getenv("SWIFTUSD_REF")
        openusd = os.getenv("OPENUSD_REF")
        swiftusd_tests = os.getenv("SWIFTUSD_TESTS_REF")

    class TestCombination:
        target_platform = os.getenv("TARGET_PLATFORM")
        config = os.getenv("CONFIG")
        build_system = os.getenv("BUILD_SYSTEM")
        github_run_id = os.getenv("GITHUB_RUN_ID")

    class Path:
        swiftusd = _getenvpath("SWIFTUSD_PATH")
        swiftusd_tests = _getenvpath("SWIFTUSD_TESTS_PATH")
        openusd = _getenvpath("OPENUSD_PATH")
        result_bundle = _getenvpath("RESULT_BUNDLE_PATH")
        github_output = _getenvpath("GITHUB_OUTPUT")
        github_step_summary = _getenvpath("GITHUB_STEP_SUMMARY")
        tmp_dir = _getenvpath("RUNNER_TEMP")
        github_workspace = _getenvpath("GITHUB_WORKSPACE")
        matrix_result = _getenvpath("MATRIX_RESULT_PATH")
        matrix_results = _getenvpath("MATRIX_RESULTS_PATH")