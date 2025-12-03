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

def write(output=None, summary=None):
    """Writes to $GITHUB_OUTPUT or $GITHUB_STEP_SUMMARY"""
    if output is not None:
        with open(Environment.Path.github_output, "a") as f:
            f.write(output + "\n")

    if summary is not None:
        with open(Environment.Path.github_step_summary, "a") as f:
            f.write(summary + "\n")

def printAndWrite(output=None, summary=None, matrixResult=None):
    """Prints and writes to $GITHUB_OUTPUT or $GITHUB_STEP_SUMMARY"""
    if output is not None: print(output)
    if summary is not None: print(summary)
    write(output=output, summary=summary)

def annotate(notice=None, warning=None, error=None, title=None):
    """Emits a notice, warning, or error annotation"""
    if notice is not None:
        cmd = "notice"
        msg = notice
    elif warning is not None:
        cmd = "warning"
        msg = warning
    elif error is not None:
        cmd = "error"
        msg = error

    # URL-encode newlines to try to get GH to support multi-line annotations
    msg = msg.replace("\n", "%0A")

    if title is not None:
        print(f"::{cmd} title={title}::{msg}")
    else:
        print(f"::{cmd}::{msg}")