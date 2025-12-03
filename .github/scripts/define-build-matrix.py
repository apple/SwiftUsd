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
import json

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--targets", required=True)
    args = parser.parse_args()

    all_targets = ["macOS", "iOS", "iOSSimulator", "visionOS", "visionOSSimulator"]

    if args.targets == "ALL":
        result = all_targets
    else:
        result = []
        for x in args.targets.split(","):
            x = x.strip()
            if x in all_targets:
                if x not in result:
                    result.append(x)
            else:
                raise ValueError(f"Unknown target '{x}'")

    result = {"target" : result}

    printAndWrite(output=f"matrix={json.dumps(result)}")