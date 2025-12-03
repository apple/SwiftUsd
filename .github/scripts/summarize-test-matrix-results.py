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

def explain_errors(axes, results, action):
    if any([x for x in results if x.returncode != 0 and x.action == action]):
        hypothesis = find_hypothesis(axes, results, action)
        printAndWrite(summary=hypothesis)

    else:
        printAndWrite(summary=f"✅ No {action} errors occurred")

def explain_times(axes, results, action):
    timesAndInstances = []
    for x in results:
        t = x.build_time if action == "build" else x.test_time
        if t <= 0: continue
        timesAndInstances.append((t, x))

    if not timesAndInstances:
        printAndWrite(summary=f"No {action} times to summarize")
        return

    timesAndInstances.sort(key=lambda x: x[0])
    nTimes = len(timesAndInstances)
    minTime = timesAndInstances[0]
    maxTime = timesAndInstances[-1]
    medianTime = timesAndInstances[int(len(timesAndInstances) / 2)]
    meanTime = sum([x[0] for x in timesAndInstances]) / len(timesAndInstances)

    title = f"{action[0].upper() + action[1:]} times ({nTimes} instances, median {medianTime[0]:.1f}s, {minTime[0]:.1f}s - {maxTime[0]:.1f}s)"
    body = [
        "```",
        f"action: {action}",
        f"instances: {nTimes}",
        f"average: {meanTime}",
        f"median: {medianTime[0]}, {medianTime[1].summary(axes)}",
        f"min: {minTime[0]}, {minTime[1].summary(axes)}",
        f"max: {maxTime[0]}, {maxTime[1].summary(axes)}",
    ]
    for x in timesAndInstances:
        body.append(f"{x[1].summary(axes)}: {x[0]}")
    body.append("```")
    body = "\n".join(body)

    printAndWrite(summary=collapsedSection(title=title, body=body))

def makeFakeData():
    """Make fake test matrix result data, for testing summarization"""
    print("Making fake data...")
    result = []
    for target_platform in ["macOS", "iOSSimulator", "visionOSSimulator"]:
        for config in ["Debug", "Release"]:
            for build_system in ["xcodebuild-xcodeproj", "swiftbuild-SPM-Tests", "xcodebuild-SPM-Tests"]:
                isFailure = False
                action = "test"

                if target_platform == "macOS" and config == "Release":
                    isFailure = True

                if build_system == "swiftbuild-SPM-Tests":
                    isFailure = True

                if target_platform == "macOS" and build_system == "xcodebuild-xcodeproj":
                    continue

                if build_system == "swiftbuild-SPM-Tests" and target_platform != "macOS":
                    continue

                if target_platform == "iOSSimulator" and config == "Debug" and build_system == "xcodebuild-xcodeproj":
                    isFailure = True
                    action = "build"

                x = TestMatrixResult()
                x.action = action
                x.returncode =  1 if isFailure else 0
                x.target_platform = target_platform
                x.config = config
                x.build_system = build_system
                x.extracted_lines = [
                    "err 3",
                    "err 4"
                ]
                x.build_time = 301.2
                x.test_time = 24.5

                result.append(x)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--makeFakeData", action="store_true")
    args = parser.parse_args()

    results = TestMatrixResult.load_all()

    if args.makeFakeData:
        results = makeFakeData()

    axes = Axes.fromTestMatrixResults(results)
    explain_errors(axes, results, "build")
    printAndWrite(summary="")
    explain_errors(axes, results, "test")
    printAndWrite(summary="")

    title = "All extracted lines"
    body = formExtractedLinesFromResults(axes, results)
    printAndWrite(summary=collapsedSection(title=title, body=body))
    printAndWrite(summary="")

    explain_times(axes, results, "build")
    printAndWrite(summary="")
    explain_times(axes, results, "test")

    # Important: If any test instances fail, we want
    # the overall test workflow to be marked as failed.
    # But since we let test instances continue after failure,
    # GitHub won't mark it as failed unless this job fails
    if any([x for x in results if x.returncode != 0]):
        exit(1)
    else:
        exit(0)