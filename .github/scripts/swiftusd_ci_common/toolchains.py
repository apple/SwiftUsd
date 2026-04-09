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
from .subprocesses import *
import os
import re
import json
import tempfile

def passesDenylist(x, denylist):
    if denylist is None: return True
    
    result = True
    for rule in denylist.split(","):
        if len(rule) == 0: continue
        if rule[0] != "-" and rule[0] != "+":
            raise ValueError(f"Illegal denylist '{denylist}'")
        if re.search(rule[1:], x) is not None:
            result = rule[0] == "+"
        
    return result

# MARK: Introspection

def parseToolchainProvider(tc=None):
    if tc is None: tc = Environment.TestCombination.toolchain_provider
    m = re.fullmatch("swiftly=(.*),xcode=(.*)", tc)
    if m is None:
        raise ValueError(f"Unable to parse toolchain provider '{tc}'")
    return (m.group(1), m.group(2))

def parseSwiftlyToolchainProvider(tc=None): return parseToolchainProvider(tc=tc)[0]
def parseXcodeToolchainProvider(tc=None): return parseToolchainProvider(tc=tc)[1]

def getAvailableXcodeVersions():
    apps = os.listdir("/Applications")
    result = []
    for x in apps:
        if m := re.fullmatch(r"Xcode(.*)\.app", x):
            result.append(x)

    result = [x for x in result if passesDenylist(x, Environment.TestCombination.xcode_denylist)]

    return result

def getAvailableSwiftlyToolchains(allow_assume_installed=True):
    if not activateSwiftly(): return []
    swiftly_list = run(["swiftly", "list", "--format", "json"],
                       allowToolchainProviderInterposing=False)
    json_blob = json.loads("\n".join(swiftly_list.output))

    result = []
    for toolchain in json_blob["toolchains"]:
        name = toolchain["version"]["name"]
        result.append(name)

    if allow_assume_installed:
        for x in (Environment.TestCombination.swiftly_assume_installed or "").split(","):
            if all([not y.startswith(x) for y in result]):
                result.append(x)

    result = [x for x in result if passesDenylist(x, Environment.TestCombination.swiftly_denylist)]

    return result

def getAllToolchainProviders():
    result = []
    for toolchain in getAvailableSwiftlyToolchains():
        if toolchain == "xcode":
            for xcode in getAvailableXcodeVersions():
                result.append(f"swiftly=xcode,xcode={xcode}")
        else:
            result.append(f"swiftly={toolchain},xcode=")

    if len(result) == 0:
        result.append("swiftly=,xcode=")

    return result

def getVersionOfToolchainProvider(x):
    (swiftly, xcode) = parseToolchainProvider(x)
    if swiftly != "xcode": return swiftly

    args = ["xcodebuild", "-version"]
    env = os.environ.copy()
    interposeToolchainProvider(args, env, x)
    proc = run(args, env=env, allowToolchainProviderInterposing=False)

    # Xcode 26.3
    result = proc.output[0]
    # 26.3
    result = result.removeprefix("Xcode ")
    return result

def isVersionLessThan(a, b):
    a_parts = a.removesuffix("-snapshot").split(".")
    b_parts = b.removesuffix("-snapshot").split(".")
    
    for i in range(min(len(a_parts), len(b_parts))):
        try:
            a_part = int(a_parts[i])
        except:
            a_part = 0

        try:
            b_part = int(b_parts[i])
        except:
            b_part = 0

        if a_part < b_part: return True
        if b_part < a_part: return False

    return False    

# MARK: Actions

def toolchainPrepareOnce():
    if not activateSwiftly(): return
    toolchain = parseSwiftlyToolchainProvider()
    if toolchain:
        swiftlyInstall(toolchain)

def getToolchainPath(name):
    # `swiftly use -p` will give the path to the active toolchain.
    # `swiftly run swiftly use -p +name` should work, but it doesn't.
    # We have to make sure we don't mess with any global state.
    #
    # Luckily, `swiftly run which swift +foo` will give us
    # the path to the swift binary within that toolchain
    proc = run(["swiftly", "run", "which", "swift", f"+{name}"],
               allowToolchainProviderInterposing=False)
    
    # /path/to/toolchain/usr/bin/swift
    whichSwift = pathlib.Path(proc.output[0])
    # /path/to/toolchain
    return str(whichSwift.parent.parent.parent)


def getToolchainBundleIdentifier(path):
    return run(["defaults", "read", path + "/Info", "CFBundleIdentifier"],
               allowToolchainProviderInterposing=False).output[-1]
    

def interposeToolchainProvider(args, env, tc=None):
    if tc is None: tc = Environment.TestCombination.toolchain_provider
    if tc is None: return

    

    (swiftly_toolchain, xcode_version) = parseToolchainProvider(tc)

    """
    xcodebuild, swift build, swiftly, xcode-select, DEVELOPER_DIR, and TOOLCHAINS interact in complex ways.
    xcodebuild and swift build use different processes to try to determine the active toolchain to use. 

    xcodebuild commands:
    - If the TOOLCHAINS environment variable is set to a valid value, use that toolchain.
    - Otherwise, if the DEVELOPER_DIR environment variable is set to a valid value, use the toolchain from that Xcode.
    - Otherwise, use the toolchain from xcode-select -p
    Note: xcodebuild is not affected by swiftly run ... +foo

    swift build commands:
    - If run within a swiftly run ... +foo context where foo is not xcode, use the foo toolchain.
    - Otherwise, if the TOOLCHAINS environment variable is set to a valid value, use that toolchain.
    - Otherwise, if the DEVELOPER_DIR environment variable is set to a valid value, use the toolchain from that Xcode.
    - Otherwise, use the toolchain from xcode-select -p

    xcodebuild and swift build both require a CPLUS_INCLUDE_PATH override to find <swift/bridging> iff the used toolchain
    is not provided by Xcode.

    So, how do I build with X toolchain? It depends on if you're using swift build or xcodebuild. For swift build:
    - If X is a toolchain installed by swiftly, set TOOLCHAINS to its bundle identifier, and set CPLUS_INCLUDE_PATH to match
    - If X is an Xcode toolchain, set DEVELOPER_DIR to it.
    For xcodebuild, do the same thing, but instead of setting `TOOLCHAINS=foo` environment variable, pass `-toolchains foo`.
    The environment variable and command line argument _should_ behave the same, but in practice setting the environment variable
    causes obscure package resolution errors that `-toolchains` avoids.
    See also the comment in .github/scripts/run-test-helper.py about resolving package dependencies before both
    building and running; xcodebuild package resolution with custom toolchains is very finnicky and tied to the exact
    environment variable mapping, thus using the TOOLCHAINS environment variable with xcodebuild can lead to
    _extremely_ bizarre, hard to reproduce, and generally flakey behavior. 
    

    How do I get the bundle identifier of a toolchain installed by swiftly?
    - defaults read <path-to-toolchain>/Info CFBundleIdentifier
    """

    def printExported(k):
        print(f"export {k}={env[k]}")

    if swiftly_toolchain != "" and swiftly_toolchain != "xcode":
        # We're trying to use a toolchain installed by swiftly
        toolchainPath = getToolchainPath(swiftly_toolchain)
        toolchainBundleIdentifier = getToolchainBundleIdentifier(toolchainPath)

        shouldModifyArgs = args[0] == "xcodebuild"
        shouldModifyEnv = not shouldModifyArgs

        if args[:2] == ["xcodebuild", "clean"] or args[:2] == ["xcodebuild", "-resolvePackageDependencies"]:
            # See the discussion in this file and in .github/scripts/run-test-helper.py
            # about resolving package dependencies. Tl;dr, setting a custom swiftly toolchain
            # will break `xcodebuild clean` and `xcodebuild -resolvePackageDependencies`,
            # and we need those commands to work in order to be able to use a custom swiftly
            # toolchain with `xcodebuild build-without-testing` or `xcodebuild test-without-building`
            #
            # rdar://174027858 (Setting TOOLCHAINS to the bundle identifier of an installed toolchain makes `xcodebuild clean` fail within a Swift Package directory)
            shouldModifyArgs = False
            shouldModifyEnv = False
        
        if shouldModifyArgs:
            # Important: Don't reassign to args, otherwise the caller won't see
            # our modifications
            args.append("-toolchain")
            args.append(toolchainBundleIdentifier)

        if shouldModifyEnv:
            env["TOOLCHAINS"] = toolchainBundleIdentifier
            printExported("TOOLCHAINS")
        else:
            env.pop("TOOLCHAINS", None)
            print("unset TOOLCHAINS")

        newCplusIncludePath = env.get("CPLUS_INCLUDE_PATH", "")
        newCplusIncludePath = f"{toolchainPath}/usr/include:{newCplusIncludePath}"
        env["CPLUS_INCLUDE_PATH"] = newCplusIncludePath
        printExported("CPLUS_INCLUDE_PATH")

        env["SWIFT_BACKTRACE"] = "interactive=no"
        printExported("SWIFT_BACKTRACE")
        
    if xcode_version:
        env["DEVELOPER_DIR"] = f"/Applications/{xcode_version}"
        printExported("DEVELOPER_DIR")

def activateSwiftly():
    paths = [os.path.expanduser("~/.swiftly/env.sh"), "/opt/swiftly/env.sh"]
    paths = [p for p in paths if os.path.exists(p)]
    if len(paths) == 0:
        print("Warning! Couldn't find a .swiftly/env.sh file")
        return False

    proc = run(["bash", "-c", f"source {paths[0]} && env"], allowToolchainProviderInterposing=False)
    for line in proc.output:
        components = line.split("=", 1)
        if len(components) != 2:
            print(f"Error! Unexpected output from env: '{line}'")
            exit(1)

        os.environ[components[0]] = components[1]
        
    swiftlyUnlink()
    return True

def swiftlyUnlink():
    run(["swiftly", "unlink"], allowToolchainProviderInterposing=False)

def swiftlyInstall(toolchain):
    """Does nothing if the toolchain is already installed"""
    if toolchain in getAvailableSwiftlyToolchains(allow_assume_installed=False): return
    run(["swiftly", "install", toolchain, "--assume-yes", "--verbose"],
        allowToolchainProviderInterposing=False)

