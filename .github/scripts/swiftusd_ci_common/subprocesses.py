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

import subprocess

class RunResult:
    def __init__(self, returncode, output):
        self.returncode = returncode
        self.output = output

def run(args, cwd=None, env=None, input=None, logCmd=True, logOutput=True, check=True):
    """Runs the given command in a subprocess"""
    cmd_as_string = " ".join([str(x) for x in args])
    if input is not None:
        cmd_as_string = f"{cmd_as_string} <<< \"{input}\""

    if logCmd:
        print(cmd_as_string)
    p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT, cwd=cwd, env=env)

    result = RunResult(None, [])

    if input is not None:
        (stdout_data, stderr_data) = p.communicate(input=input.encode("utf-8"))
        if stderr_data is not None:
            result.output.append(stderr_data.decode("utf-8"))
            if logOutput and result.output[-1]: print(result.output[-1], end="", flush=True)
        if stdout_data is not None:
            result.output.append(stdout_data.decode("utf-8"))        
            if logOutput and result.output[-1]: print(result.output[-1], end="", flush=True)

    else:
        while True:
            l = p.stdout.readline().decode("utf-8")
            result.output.append(l)
            if l:
                if logOutput:
                    print(l, end="", flush=True)
            elif p.poll() is not None:
                break

    result.returncode = p.returncode
    result.output = [x for l in result.output for x in l.splitlines() ]

    if check and result.returncode != 0:
        print(f"'{cmd_as_string}' exited with returncode {p.returncode}:")
        if not logOutput:
            print("\n".join(result.output))

        exit(result.returncode)

    return result