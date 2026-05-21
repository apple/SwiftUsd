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

def perform_high_level_breakdown(results):
    n_build_errors = len([x for x in results if x.matchesOutcome("build failure")])
    n_test_errors = len([x for x in results if x.matchesOutcome("test failure")])
    n_successes = len([x for x in results if x.matchesOutcome("success")])
    n_total = Environment.TestCombination.n_combinations
    printAndWrite(summary=f"Build errors: {n_build_errors}, test errors: {n_test_errors}, successes: {n_successes}, total test combinations: {n_total}")

def explain_outcomes(axes, results, outcome):
    if any([x for x in results if x.matchesOutcome(outcome)]):
        hypothesis = find_hypothesis(axes, results, outcome)
        printAndWrite(summary=hypothesis)

    else:
        if outcome == "success":
            printAndWrite(summary=f"❌ No successes occurred")
        else:
            printAndWrite(summary=f"✅ No {outcome}s occurred")

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


if __name__ == "__main__":
    results = TestMatrixResult.load_all()

    axes = Axes.fromTestMatrixResults(results)
    perform_high_level_breakdown(results)
    printAndWrite(summary="")
    explain_outcomes(axes, results, "build failure")
    printAndWrite(summary="")
    explain_outcomes(axes, results, "test failure")
    printAndWrite(summary="")
    explain_outcomes(axes, results, "success")
    printAndWrite(summary="")

    superTitle = f"All extracted lines: ({len(results)} combinations)"
    superBody = []
    for x in results:
        title = x.summary(axes)
        body = ["```"] + x.extracted_lines + ["```"]
        if len(x.extracted_lines) == 0:
            title += ": (none)"
            body = []
        else:
            title += f": ({len(x.extracted_lines)} lines)"
        body = "\n".join(body)
        superBody.append(collapsedSection(title=title, body=body))
    superBody = "\n".join(superBody)
    printAndWrite(summary=collapsedSection(title=superTitle, body=superBody))
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
