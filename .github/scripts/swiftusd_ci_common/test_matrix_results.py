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
from .markdown import *
from .subprocesses import *
import json
import os
import random
import pprint
import time
import copy
import re

# MARK: TestMatrixResult

class TestMatrixResult:
    def __init__(self):
        raw_swift_version = "\n".join(run(["swift", "--version"]).output)
        short_swift_version = re.search(r"version (.*) \(", raw_swift_version).group(1)
        raw_sw_vers = "\n".join(run(["sw_vers"]).output)
        short_sw_vers = run(["sw_vers", "--productVersion"]).output[0] + " (" + run(["sw_vers", "--buildVersion"]).output[0] + ")"
        raw_xcodebuild_version = "\n".join(run(["xcodebuild", "-version"]).output)
        short_xcodebuild_version = re.search(r"Xcode (.*)", raw_xcodebuild_version).group(1) + " (" + re.search(r"Build version (.*)", raw_xcodebuild_version).group(1) + ")"
        if Environment.GitRef.swiftusd and Environment.Path.swiftusd:
            swiftusd_ref = run(["git", "rev-parse", Environment.GitRef.swiftusd], cwd=Environment.Path.swiftusd).output[0]
        else:
            swiftusd_ref = "null"

        if Environment.GitRef.swiftusd_tests and Environment.Path.swiftusd_tests:
            swiftusd_tests_ref = run(["git", "rev-parse", Environment.GitRef.swiftusd_tests], cwd=Environment.Path.swiftusd_tests).output[0]
        else:
            swiftusd_tests_ref = "null"

        self.data = {
            "action": "null",
            "matrix_instance" : {
                "target_platform": Environment.TestCombination.target_platform,
                "config": Environment.TestCombination.config,
                "build_system": Environment.TestCombination.build_system,
            },
            "output" : {
                "returncode": -2,
                "build_time": -1.0,
                "test_time": -1.0,
                "extracted_lines": [],
            },
            "extra_info" : {
                "raw_swift_version": raw_swift_version,
                "short_swift_version": short_swift_version,
                "raw_sw_vers": raw_sw_vers,
                "short_sw_vers": short_sw_vers,
                "raw_xcodebuild_version": raw_xcodebuild_version,
                "short_xcodebuild_version": short_xcodebuild_version,
                "rev_parse_swiftusd_ref": swiftusd_ref,
                "rev_parse_swiftusd_tests_ref": swiftusd_tests_ref,
            },
        }

    def matrixInstanceSummary(self):
        return " ".join([v for v in self.data["matrix_instance"].values()])

    def setExtractedLinesToTimeout(self, action):
        self.extracted_lines = [f"{action} timeout: {self.matrixInstanceSummary()}"]

    def niceAxisName(self, k):
        if k == "target_platform": return "target platform"
        if k == "config": return "config"
        if k == "build_system": return "build system"
        if k == "raw_swift_version": return "swift version"
        if k == "short_swift_version": return "swift version"
        if k == "raw_sw_vers": return "host OS"
        if k == "short_sw_vers": return "host OS"
        if k == "raw_xcodebuild_version": return "Xcode version"
        if k == "short_xcodebuild_version": return "Xcode version"
        if k == "rev_parse_swiftusd_ref": return "SwiftUsd ref"
        if k == "rev_parse_swiftusd_tests_ref": return "SwiftUsd-Tests ref"

        return k

    @property
    def action(self): return self.data["action"]
    @action.setter
    def action(self, value): self.data["action"] = value

    @property
    def returncode(self): return self.data["output"]["returncode"]
    @returncode.setter
    def returncode(self, value): self.data["output"]["returncode"] = value

    @property
    def extracted_lines(self): return self.data["output"]["extracted_lines"]
    @extracted_lines.setter
    def extracted_lines(self, value): self.data["output"]["extracted_lines"] = value

    @property
    def build_time(self): return self.data["output"]["build_time"]
    @build_time.setter
    def build_time(self, value): self.data["output"]["build_time"] = value

    @property
    def test_time(self): return self.data["output"]["test_time"]
    @test_time.setter
    def test_time(self, value): self.data["output"]["test_time"] = value

    @property
    def target_platform(self): return self.data["matrix_instance"]["target_platform"]
    @target_platform.setter
    def target_platform(self, value): self.data["matrix_instance"]["target_platform"] = value

    @property
    def config(self): return self.data["matrix_instance"]["config"]
    @config.setter
    def config(self, value): self.data["matrix_instance"]["config"] = value

    @property
    def build_system(self): return self.data["matrix_instance"]["build_system"]
    @build_system.setter
    def build_system(self, value): self.data["matrix_instance"]["build_system"] = value

    @property
    def isFailure(self): return self.returncode != 0

    def write(self):
        with open(Environment.Path.matrix_result, "w") as f:
            json.dump(self.data, f)

    @staticmethod
    def load(p=None):
        if p is None: p = Environment.Path.matrix_result
        if not p.exists():
            return TestMatrixResult()

        with open(p, "r") as f:
            x = TestMatrixResult()
            x.data = json.load(f)
            return x

    @staticmethod
    def load_all():
        result = []
        for (dirpath, dirnames, filenames) in os.walk(Environment.Path.matrix_results):
            for f in filenames:
                if f.endswith(".json"):
                    result.append(TestMatrixResult.load(pathlib.Path(dirpath) / f))
        return result

    @property
    def axisValues(self):
        result = []

        for k, v in self.data["matrix_instance"].items():
            result.append(AxisValue(k, v))

        for k, v in self.data["extra_info"].items():
            result.append(AxisValue(k, v))

        return result

    def summary(self, axes):
        x = ", ".join([f"{self.niceAxisName(k)} = {self.valueForAxis(k)}" for k in axes.get_all_axes_names()])
        return x[0].upper() + x[1:]

    def valueForAxis(self, axis):
        for a in self.axisValues:
            if a.axis == axis: return a.value

# MARK: Hypothesis discovery

class Axes:
    def __init__(self, data):
        self._data = copy.deepcopy(data)

    def get_all_axes_names(self):
        return list(self._data.keys())

    def get_all_values_for_axis(self, k):
        return self._data[k]

    def get_number_of_axes(self):
        return len(self._data)

    def get_cartesian_product(self):
        result = [[]]
        for axis in self.get_all_axes_names():
            result = [x + [AxisValue(axis, value)] for value in self.get_all_values_for_axis(axis) for x in result]
        return result

    def get_all_axes_values(self):
        result = []
        for k in self.get_all_axes_names():
            for v in self.get_all_values_for_axis(k):
                result.append(AxisValue(k, v))
        return result

    @staticmethod
    def fromTestMatrixResults(testMatrixResults):
        d = {}
        for testMatrixResult in testMatrixResults:
            for axisValue in testMatrixResult.axisValues:
                if axisValue.axis not in d:
                    d[axisValue.axis] = []
                if axisValue.value not in d[axisValue.axis]:
                    d[axisValue.axis].append(axisValue.value)

        # If there's at most one value for a field, it isn't an axis
        # of variability, but including it as an axis could
        # lead to combinatorial explosion when trying to find
        # hypotheses
        d = {k : v for k, v in d.items() if len(v) >= 2}

        return Axes(d)

    def __str__(self):
        return str(self._data)

    def __repr__(self): return str(self)


class AxisValue:
    def __init__(self, axis, value):
        self.axis = axis
        self.value = value

    def __str__(self):
        return f"{self.axis} = {self.value}"

    def __repr__(self): return str(self)

    def __eq__(self, other):
        return self.axis == other.axis and self.value == other.value

class Hyperplane:
    def __init__(self, axes_values):
        self.axes_values = axes_values

    def appendingAxisValue(self, axisValue):
        return Hyperplane(self.axes_values + [axisValue])

    def getTestCaseIntersection(self, test_cases):
        result = []
        for tc in test_cases:
            if all([tc.valueForAxis(av.axis) == av.value for av in self.axes_values]):
                result.append(tc)

        return result

    def __str__(self):
        if self.axes_values:
            return ", ".join([str(x) for x in self.axes_values])
        else:
            return "All instances"

    def __repr__(self): return str(self)

def formExtractedLinesFromResults(axes, results):
    ans = []
    for x in results:
        if len(x.extracted_lines) > 0:
            ans += [x.summary(axes) + ":", "```"] + x.extracted_lines + ["```"]
        else:
            ans += [x.summary(axes) + ": (none)  "]

    return "\n".join(ans)

def find_hypothesis(axes, test_cases, action):
    print(f"Finding {action} hypothesis with axes:")
    pprint.pprint(axes)
    print("and test cases:")
    print([x.summary(axes) for x in test_cases])
    print("")

    hyperplanes = [Hyperplane([])]

    capitalizedAction = action[0].upper() + action[1:]
    result = [
        f"❌ {capitalizedAction} failures occurred in these combinations:",
    ]

    test_cases = copy.deepcopy(test_cases)

    while hyperplanes:
        h = hyperplanes.pop(0)
        intersection = h.getTestCaseIntersection(test_cases)
        if all([not x.isFailure for x in intersection]):
            continue
        if all([x.isFailure and x.action == action for x in intersection]):
            title = f"{h} ({len(intersection)} instances)"
            body = formExtractedLinesFromResults(axes, intersection)

            result.append(collapsedSection(title=title, body=body))

            for i, tc in reversed(list(enumerate(test_cases))):
                if tc in intersection:
                    del test_cases[i]
            continue

        for av in axes.get_all_axes_values():
            if av not in h.axes_values:
                hyperplanes.append(h.appendingAxisValue(av))

    return "\n".join(result)

