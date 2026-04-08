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
import argparse
import re

def quiet_run(args):
    return run(args, cwd=Environment.Path.swiftusd, logOutput=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("swiftusd_tag")
    args = parser.parse_args()

    unstaged =  quiet_run(["git", "status", "--porcelain=v1"]).output
    modified_files = []
    for l in unstaged:
        # porcelain format: <xy> <path> or <xy> <orig-path> -> <path>,
        # where xy is a two-character status code
        l = l[3:]
        if m := re.match("(.*)->(.*)", l):
            modified_files.append(m.group(1).strip())
            modified_files.append(m.group(2).strip())
        else:
            modified_files.append(l.strip())

    modified_roots = set()
    for f in modified_files:
        if m := re.match("([^/]*)/.*", f):
            modified_roots.add(m.group(1))
        else:
            modified_roots.add(f)

    required_roots = ["swift-package", "docs", "SwiftUsd.doccarchive"]
    expected_roots = ["Package.swift"]
    had_error = False

    for r in required_roots:
        if r not in modified_roots:
            print(f"Error: {r} was not modified")
            had_error = True
        modified_roots.discard(r)

    for r in expected_roots:
        if r not in modified_roots:
            print(f"Warning: {r} was not modified")
        modified_roots.discard(r)

    if len(modified_roots) != 0:
        print(f"Error: unexpected modifications: {modified_roots}")
        had_error = True

    if had_error:
        exit(1)

    quiet_run(["git", "add", "-A"])
    quiet_run(["git", "commit", "-m", f"Publish documentation and update swift-package for SwiftUsd {args.swiftusd_tag}"])
    quiet_run(["git", "tag", args.swiftusd_tag])


    printAndWrite(summary=f"""To release SwiftUsd {args.swiftusd_tag}, run:
```
cd {Environment.Path.swiftusd}
git push
git push origin {args.swiftusd_tag}
```
Remember to run these commands in SwiftUsd-Tests and SwiftUsd-ast-answerer:
```
git tag {args.swiftusd_tag}
git push
git push origin {args.swiftusd_tag}
```""")
