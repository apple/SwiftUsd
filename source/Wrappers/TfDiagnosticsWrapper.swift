//===----------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0
//===----------------------------------------------------------------------===//

// Due to pxr::TfEnum::TfEnum(_:_:) using enable_if, Swift can't import
// that constructor. Due to https://github.com/swiftlang/swift/issues/83081 (Templated C++ function incorrectly imported as returning Void in Swift),
// we can't wrap the TfEnum constructor in a simpler templated function.
// So, there's no way to create an accessible initializer/function taking
// a generic/templated argument returning TfEnum short of writing
// out one function for every single possible enum type. So, the TfEnum
// overloads are provided for completeness, and are usable if you can
// construct the TfEnum in C++, but aren't particularly useful at the moment.

/*
There are a lot of TF_FOO macros in C++, and we want to expose all of them as
Swift functions where possible, using Swift macros as a last resort.
The C++ macros use VA_ARGS, which makes keeping track of which overloads are possible
a bit tricky. So, there are some notes in comments in this file that I found useful
while implementing these the first time. 



_ file: StaticString = #filePath,
_ function: StaticString = #function,
_ line: Int = #line,
_ prettyFunction: StaticString = #function

Tf_PostErrorHelper:
TfEnum + std.string
TfDiagnosticType + std.string
TfDiagnosticInfo + TfEnum + std.string

Tf_PostQuietlyErrorHelper:
TfEnum + TfDiagnosticInfo + std.string
TfEnum + std.string

Tf_PostWarningHelper:
std.string
TfEnum + std.string
TfDiagnosticType + std.string
TfDiagnosticInfo + TfEnum + std.string

Tf_PostStatusHelper:
std.string
TfEnum + std.string
TfDiagnosticInfo + TfEnum + std.string

Tf_DiagnosticHelper.foo:
std.string

- TF_CODING_ERROR: Tf_PostErrorHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE)
- TF_FATAL_CODING_ERROR: Tf_DiagnosticHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE).IssueFatalError
- TF_CODING_WARNING: Tf_PostWarningHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE)
- TF_DIAGNOSTIC_WARNING: Tf_DiagnosticHelper(Hide(), TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning
- TF_RUNTIME_ERROR: Tf_PostErrorHelper(TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE)
- TF_FATAL_ERROR: Tf_DiagnosticHelper(TF_DIAGNOSTIC_FATAL_ERROR_TYPE).IssueFatalError
- TF_DIAGNOSTIC_FATAL_ERROR: Tf_DiagnosticHelper(TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE).IssueFatalError
- TF_DIAGNOSTIC_NONFATAL_ERROR: Tf_DiagnosticHelper(TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning
- TF_WARN: Tf_PostWarningHelper()
- TF_STATUS: Tf_PostStatusHelper()
- TF_ERROR: Tf_PostErrorHelper()
- TF_QUIET_ERROR: Tf_PostQuietlyErrorHelper()
- TF_VERIFY: complex
- TF_AXIOM: complex
- TF_DEV_AXIOM: complex
*/

fileprivate func _makeTfCallContext(
    file: StaticString,
    function: StaticString,
    line: Int,
    prettyFunction: StaticString
) -> pxr.TfCallContext {
    pxr.TfCallContext(file.utf8Start,
                      function.utf8Start,
                      line,
                      prettyFunction.utf8Start)
}

fileprivate func _makeHiddenTfCallContext(
    file: StaticString,
    function: StaticString,
    line: Int,
    prettyFunction: StaticString
) -> pxr.TfCallContext {
    pxr.TfCallContext(file.utf8Start,
                      function.utf8Start,
                      line,
                      prettyFunction.utf8Start)
                      .Hide().pointee
}


// MARK: TF_ERROR
// Tf_PostErrorHelper() =>
//   TfEnum + std.string
//   TfDiagnosticType + std.string
//   TfDiagnosticInfo + TfEnum + std.string

public func TF_ERROR(_ tfEnum: pxr.TfEnum, _ message: std.string,
                     _ file: StaticString = #filePath,
                     _ function: StaticString = #function,
                     _ line: Int = #line,
                     _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostErrorHelper(callContext, tfEnum, message)
}

public func TF_ERROR(_ tfDiagnosticType: pxr.TfDiagnosticType, _ message: std.string,
                     _ file: StaticString = #filePath,
                     _ function: StaticString = #function,
                     _ line: Int = #line,
                     _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostErrorHelper(callContext, tfDiagnosticType, message)
}

public func TF_ERROR(_ tfDiagnosticInfo: pxr.TfDiagnosticInfo, _ tfEnum: pxr.TfEnum, _ message: std.string,
                     _ file: StaticString = #filePath,
                     _ function: StaticString = #function,
                     _ line: Int = #line,
                     _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostErrorHelper(callContext, tfDiagnosticInfo, tfEnum, message)
}

// MARK: TF_RUNTIME_ERROR
// Tf_PostErrorHelper(TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE) =>
//   std.string

public func TF_RUNTIME_ERROR(_ message: std.string,
                             _ file: StaticString = #filePath,
                             _ function: StaticString = #function,
                             _ line: Int = #line,
                             _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostErrorHelper(callContext, pxr.TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE, message)
}

// MARK: TF_CODING_ERROR
// Tf_PostErrorHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE) =>
//    std.string

public func TF_CODING_ERROR(_ message: std.string,
                            _ file: StaticString = #filePath,
                            _ function: StaticString = #function,
                            _ line: Int = #line,
                            _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostErrorHelper(callContext, pxr.TF_DIAGNOSTIC_CODING_ERROR_TYPE, message)
}

// MARK: TF_STATUS
// Tf_PostStatusHelper() =>
//   std.string
//   TfEnum + std.string
//   TfDiagnosticInfo + TfEnum + std.string

public func TF_STATUS(_ message: std.string,
                      _ file: StaticString = #filePath,
                      _ function: StaticString = #function,
                      _ line: Int = #line,
                      _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostStatusHelper(callContext, message)
}

public func TF_STATUS(_ tfEnum: pxr.TfEnum, _ message: std.string,
                      _ file: StaticString = #filePath,
                      _ function: StaticString = #function,
                      _ line: Int = #line,
                      _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostStatusHelper(callContext, tfEnum, message)
}

public func TF_STATUS(_ tfDiagnoticInfo: pxr.TfDiagnosticInfo, _ tfEnum: pxr.TfEnum, _ message: std.string,
                      _ file: StaticString = #filePath,
                      _ function: StaticString = #function,
                      _ line: Int = #line,
                      _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostStatusHelper(callContext, tfDiagnoticInfo, tfEnum, message)
}

// MARK: TF_WARN
// Tf_PostWarningHelper() =>
//   std.string
//   TfEnum + std.string
//   TfDiagnosticType + std.string
//   TfDiagnosticInfo + TfEnum + std.string

public func TF_WARN(_ message: std.string,
                    _ file: StaticString = #filePath,
                    _ function: StaticString = #function,
                    _ line: Int = #line,
                    _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostWarningHelper(callContext, message)
}

public func TF_WARN(_ tfEnum: pxr.TfEnum, _ message: std.string,
                    _ file: StaticString = #filePath,
                    _ function: StaticString = #function,
                    _ line: Int = #line,
                    _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostWarningHelper(callContext, tfEnum, message)
}

public func TF_WARN(_ tfDiagnosticType: pxr.TfDiagnosticType, _ message: std.string,
                    _ file: StaticString = #filePath,
                    _ function: StaticString = #function,
                    _ line: Int = #line,
                    _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostWarningHelper(callContext, tfDiagnosticType, message)
}

public func TF_WARN(_ tfDiagnosticInfo: pxr.TfDiagnosticInfo, _ tfEnum: pxr.TfEnum, _ message: std.string,
                    _ file: StaticString = #filePath,
                    _ function: StaticString = #function,
                    _ line: Int = #line,
                    _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostWarningHelper(callContext, tfDiagnosticInfo, tfEnum, message)
}

// MARK: TF_QUIET_ERROR
// Tf_PostQuietlyErrorHelper() =>
//  TfEnum + TfDiagnosticInfo + std.string
//  TfEnum + std.string

public func TF_QUIET_ERROR(_ tfEnum: pxr.TfEnum, _ tfDiagnosticInfo: pxr.TfDiagnosticInfo, _ message: std.string,
                           _ file: StaticString = #filePath,
                           _ function: StaticString = #function,
                           _ line: Int = #line,
                           _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostQuietlyErrorHelper(callContext, tfEnum, tfDiagnosticInfo, message)
}

public func TF_QUIET_ERROR(_ tfEnum: pxr.TfEnum, _ message: std.string,
                           _ file: StaticString = #filePath,
                           _ function: StaticString = #function,
                           _ line: Int = #line,
                           _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostQuietlyErrorHelper(callContext, tfEnum, message)
}

// MARK: TF_CODING_WARNING
// Tf_PostWarningHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE) =>
//   std.string

public func TF_CODING_WARNING(_ message: std.string,
                              _ file: StaticString = #filePath,
                              _ function: StaticString = #function,
                              _ line: Int = #line,
                              _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_PostWarningHelper(callContext, pxr.TF_DIAGNOSTIC_CODING_ERROR_TYPE, message)
}

// MARK: TF_FATAL_CODING_ERROR
// Tf_DiagnosticHelper(TF_DIAGNOSTIC_CODING_ERROR_TYPE).IssueFatalError =>
//   std.string

public func TF_FATAL_CODING_ERROR(_ message: std.string,
                                  _ file: StaticString = #filePath,
                                  _ function: StaticString = #function,
                                  _ line: Int = #line,
                                  _ prettyFunction: StaticString = #function
) -> Never {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_DiagnosticHelper(callContext, pxr.TF_DIAGNOSTIC_CODING_ERROR_TYPE).IssueFatalError(message)
    fatalError("Unreachable: IssueFatalError cannot return")
}

// MARK: TF_FATAL_ERROR
// Tf_DiagnosticHelper(TF_DIAGNOSTIC_FATAL_ERROR_TYPE).IssueFatalError =>
//   std.string

public func TF_FATAL_ERROR(_ message: std.string,
                           _ file: StaticString = #filePath,
                           _ function: StaticString = #function,
                           _ line: Int = #line,
                           _ prettyFunction: StaticString = #function
) -> Never {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_DiagnosticHelper(callContext, pxr.TF_DIAGNOSTIC_FATAL_ERROR_TYPE).IssueFatalError(message)
    fatalError("Unreachable: IssueFatalError cannot return")
}

// MARK: TF_DIAGNOSTIC_FATAL_ERROR
// Tf_DiagnosticHelper(TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE).IssueFatalError =>
//   std.string

public func TF_DIAGNOSTIC_FATAL_ERROR(_ message: std.string,
                                      _ file: StaticString = #filePath,
                                      _ function: StaticString = #function,
                                      _ line: Int = #line,
                                      _ prettyFunction: StaticString = #function
) -> Never {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_DiagnosticHelper(callContext, pxr.TF_DIAGNOSTIC_RUNTIME_ERROR_TYPE).IssueFatalError(message)
    fatalError("Unreachable: IssueFatalError cannot return")
}

// MARK: TF_DIAGNOSTIC_NONFATAL_ERROR
// Tf_DiagnosticHelper(TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning =>
//   std.string

public func TF_DIAGNOSTIC_NONFATAL_ERROR(_ message: std.string,
                                         _ file: StaticString = #filePath,
                                         _ function: StaticString = #function,
                                         _ line: Int = #line,
                                         _ prettyFunction: StaticString = #function
) {
    let callContext = _makeTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_DiagnosticHelper(callContext, pxr.TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning(message)
}

// MARK: TF_DIAGNOSTIC_WARNING
// Tf_DiagnosticHelper(Hide(), TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning =>
//   std.string
public func TF_DIAGNOSTIC_WARNING(_ message: std.string,
                                  _ file: StaticString = #filePath,
                                  _ function: StaticString = #function,
                                  _ line: Int = #line,
                                  _ prettyFunction: StaticString = #function
) {
    let callContext = _makeHiddenTfCallContext(file: file, function: function, line: line, prettyFunction: prettyFunction)
    pxr.Tf_DiagnosticHelper(callContext, pxr.TF_DIAGNOSTIC_WARNING_TYPE).IssueWarning(message)
}



@discardableResult
@freestanding(expression)
public macro TF_VERIFY(_ condition: Bool, _ message: String = "") -> Bool = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "TF_VERIFY_Macro")

@discardableResult
@freestanding(expression)
public macro TF_AXIOM(_ condition: Bool) -> Bool = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "TF_AXIOM_Macro")

@discardableResult
@freestanding(expression)
public macro TF_DEV_AXIOM(_ condition: Bool) -> Bool = #externalMacro(module: "_OpenUSD_MacroImplementations", type: "TF_DEV_AXIOM_Macro")
