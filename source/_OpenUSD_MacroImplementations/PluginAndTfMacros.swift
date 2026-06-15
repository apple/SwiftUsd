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


import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// VERY IMPORTANT: This must match the value of the
// `PXR_VERSION` macro in `pxr/pxr.h` in order for the @TF_REGISTRY_FUNCTION
// and @SWIFTUSD_PLUGIN macros to work properly in Swift. Otherwise they
// will silently fail to do anything at runtime.
// It should be a String whose contents is a valid CUnsignedInt literal,
// so that it can be interpolated into code produced by macros. 
fileprivate let PXR_VERSION: String = "2605"

enum CustomError: Error, CustomStringConvertible {
    case message(String)
    
    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}

fileprivate func TF_REGISTRY_FUNCTION_Impl(context: some MacroExpansionContext,
                                           argumentTypeText: String,
                                           body: String) throws -> [DeclSyntax] {
    // Compute identifiers and attributes
    let userArchCtorName = context.makeUniqueName("arch_ctor__Tf_RegistryAdd")
    let userArchFName = context.makeUniqueName("_Tf_RegistryAdd")
    
    let archPerLibInitCtorName = context.makeUniqueName("arch_ctor__tfRegistryInit")
    let archPerLibInitFName = context.makeUniqueName("_tfRegistryInit")
    
    let stringifiedMetatypeName = "\"" + argumentTypeText + "\""

    var usedAttribute = "@_used"
    var sectionAttribute = "@_section"
    if let configuration = context.buildConfiguration {
        if configuration.compilerVersion >= .init(components: [6, 3]) {
            usedAttribute = "@used"
            sectionAttribute = "@section"
        } else if try configuration.hasFeature(name: "SymbolLinkageMarkers") {
            // pass
        } else {
            throw CustomError.message("Experimental feature 'SymbolLinkageMarkers' must be enabled to use @TF_REGISTRY_FUNCTION before Swift 6.3")
        }
    }

    let libraryNameCode: String
    if false {
        libraryNameCode = #""MFB_ALT_PACKAGE_NAME""#
    } else {
        libraryNameCode = #"#fileID.components(separatedBy: "/").first ?? "MFB_ALT_PACKAGE_NAME""#
    }

    // Finally, form the decls to return.
    // 
    // We can't use _ARCH_ENSURE_PER_LIB_INIT, so we emit a second ctor-func
    // pair with lower priority to fake it. Priority is in [0,255], with larger
    // values running later

    return [
    """
    \(raw: usedAttribute) \(raw: sectionAttribute)("__DATA,pxrctor")
    private let \(userArchCtorName): (@convention(c) () -> (), CUnsignedInt, CUnsignedInt) = (
        function: \(userArchFName),
        version: \(raw: PXR_VERSION),
        priority: 100
    )

    private func \(userArchFName)() {
        pxr.Tf_RegistryInit.Add(
            \(raw: libraryNameCode),
            { _, _ in \(raw: body) },
            \(raw: stringifiedMetatypeName)
        )
    }

    \(raw: usedAttribute) \(raw: sectionAttribute)("__DATA,pxrctor")
    private let \(archPerLibInitCtorName): (@convention(c) () -> (), CUnsignedInt, CUnsignedInt) = (
        function: \(archPerLibInitFName),
        version: \(raw: PXR_VERSION),
        priority: 200
    )

    private func \(archPerLibInitFName)() {
        pxr.Tf_RegistryInit.Add(
            \(raw: libraryNameCode),
            { _, _ in __Overlay.Tf_RegistryInitCtor(\(raw: libraryNameCode)) },
            "TfType"
        )
    }
    """
    ]
}

public struct TF_REGISTRY_FUNCTION_Macro: PeerMacro {
    static func extractMetatype(from expr: ExprSyntax) throws -> [String] {
        var result = [String]()
        var expr = expr
        
        while true {
            if let memberAccess = expr.as(MemberAccessExprSyntax.self) {
                if result.isEmpty {
                    guard memberAccess.declName.baseName.text == "self" else { throw CustomError.message("@TF_REGISTRY_FUNCTION argument must be a metatype. (Did you forget to use `.self` after the type name?)") }
                }
                result.insert(memberAccess.declName.baseName.text, at: 0)
                guard let base = memberAccess.base else { break }
                expr = base
            } else if let declReference = expr.as(DeclReferenceExprSyntax.self) {
                result.insert(declReference.baseName.text, at: 0)
                break
            } else {
                throw CustomError.message("@TF_REGISTRY_FUNCTION argument must be a metatype")
            }
        }
        
        return result
    }

    
    public static func expansion(
      of node: AttributeSyntax,
      providingPeersOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TF_REGISTRY_FUNCTION requires a single metatype argument
        var argumentTypeText: String = ""
        switch node.arguments {
        case .argumentList(let arguments):
            guard arguments.count == 1 else { throw CustomError.message("@TF_REGISTRY_FUNCTION requires one argument") }
            let metatypeComponents = try extractMetatype(from: arguments.first!.expression)
            guard metatypeComponents.first == "pxr" else { throw CustomError.message("@TF_REGISTRY_FUNCTION argument must be a metatype of an OpenUSD type") }
            guard metatypeComponents.count > 2 else { throw CustomError.message("@TF_REGISTRY_FUNCTION argument must be a metatype of an OpenUSD type") }
            argumentTypeText = metatypeComponents[1..<metatypeComponents.count - 1].joined(separator: "::")
            
        default:
            throw CustomError.message("@TF_REGISTRY_FUNCTION requires one argument")
        }
        
        // TF_REGISTRY_FUNCTION must be applied to a single top-level non-generic () -> () function
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw CustomError.message("@TF_REGISTRY_FUNCTION only works on functions")
        }
        guard context.lexicalContext.isEmpty else {
            throw CustomError.message("@TF_REGISTRY_FUNCTION can only be applied to top-level functions")
        }
        guard funcDecl.genericParameterClause == nil else {
            throw CustomError.message("@TF_REGISTRY_FUNCTION does not support generic functions")
        }
        guard funcDecl.signature.effectSpecifiers == nil else {
            throw CustomError.message("@TF_REGISTRY_FUNCTION does not support async or throwing functions")
        }
        guard funcDecl.signature.parameterClause.parameters.isEmpty else {
            throw CustomError.message("@TF_REGISTRY_FUNCTION requires a function that takes no arguments")
        }
        if let returnClause = funcDecl.signature.returnClause,
           returnClause.type.as(IdentifierTypeSyntax.self)?.name.text != "Void" {
            throw CustomError.message("@TF_REGISTRY_FUNCTION requires a function that returns Void")
        }


        return try TF_REGISTRY_FUNCTION_Impl(context: context, argumentTypeText: argumentTypeText,
                                             body: "\(funcDecl.name.text)()")
    }
}

public struct SWIFTUSD_PLUGIN_Macro: PeerMacro {
    static func extractType(from type: TypeSyntax) -> [String] {
        var result = [String]()
        var type = type
        
        while true {
            if let memberType = type.as(MemberTypeSyntax.self) {
                result.insert(memberType.name.text, at: 0)
                type = memberType.baseType
            } else if let identifierType = type.as(IdentifierTypeSyntax.self) {
                result.insert(identifierType.name.text, at: 0)
                break
            } else {
                return []
            }
        }
        
        return result
    }


    public static func expansion(
      of node: AttributeSyntax,
      providingPeersOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // SWIFTUSD_PLUGIN must be applied to a top-level non-generic final class that subclasses an OpenUSD plugin entry class
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw CustomError.message("@SWIFTUSD_PLUGIN only works on classes")
        }
        guard context.lexicalContext.isEmpty else {
            throw CustomError.message("@SWIFTUSD_PLUGIN can only be applied to top-level classes")
        }
        guard classDecl.genericParameterClause == nil else {
            throw CustomError.message("@SWIFTUSD_PLUGIN does not support generic classes")
        }
        
        guard let inheritanceClause = classDecl.inheritanceClause else {
            throw CustomError.message("@SWIFTUSD_PLUGIN only works on classes that inherit from OpenUSD classes")
        }

        var hasFinal = false
        for modifier in classDecl.modifiers {
            if modifier.name.text == "final" {
                hasFinal = true
                break
            }
        }
        guard hasFinal else {
            throw CustomError.message("@SWIFTUSD_PLUGIN can only be applied to final classes")
        }
        
        var inheritsCorrectly = false
        for inheritedType in inheritanceClause.inheritedTypes {
            if extractType(from: inheritedType.type) == ["Overlay", "HioImageSubclass"] {
                inheritsCorrectly = true
                break
            }
        }
        guard inheritsCorrectly else {
            throw CustomError.message("@SWIFTUSD_PLUGIN only works on classes that inherit from OpenUSD plugin entry classes")
        }
        
        
        // Compute identifiers
        let userClassName = classDecl.name.text
        let factoryName = "setSwiftHioImagePluginFactory"
        let adapterName = "__Overlay.HioImage.CxxAdapter"

        // Finally, form the decl to return.
        // We want to just return a `@TF_REGISTRY_FUNCTION`-annotated
        // function, but instead have to effectively expand it ourselves
        // to work around:
        // rdar://181849395 (Declarations named with `MacroExpansionContext.makeUniqueName` not visible during nested macro expansion)
        
        return try TF_REGISTRY_FUNCTION_Impl(context: context,
                                             argumentTypeText: "TfType",
                                             body:
            """
            __Overlay.\(factoryName)("\(userClassName)") {
                Unmanaged<\(adapterName)>.passUnretained(\(userClassName).new().get_cxx()!).toOpaque()
            }
            """
        )
    }
}
