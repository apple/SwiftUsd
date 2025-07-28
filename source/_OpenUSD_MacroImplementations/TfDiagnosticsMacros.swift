import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

let makeTfCallContext: ExprSyntax = """
pxr.TfCallContext((#file as StaticString).utf8Start,
                  (#function as StaticString).utf8Start,
                  #line as Int,
                  (#function as StaticString).utf8Start)
"""

public struct TF_VERIFY_Macro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        let lastHelperArgument: ExprSyntax

        if node.arguments.count == 1 {
            lastHelperArgument = "nil"
        } else {
            let secondArg = node.arguments[node.arguments.index(at: 1)].expression
            // We need to use `strdup` because the `TF_VERIFY` implementation
            // will ultimately `free()` the `char*` we give it. 
            lastHelperArgument = "strdup(\(literal: secondArg.description))"
        }

        return """
        \(argument) ? true : pxr.Tf_FailedVerifyHelper(
            \(makeTfCallContext),
            \(literal: argument.description),
            \(lastHelperArgument)
        )
        """
    }
}

public struct TF_AXIOM_Macro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return """
        pxr.Tf_AxiomHelper(\(argument),
                           \(makeTfCallContext),
                           \(literal: argument.description))
        """
    }
}

public struct TF_DEV_AXIOM_Macro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        // TF_DEV_AXIOM in C++ only evaluates the argument in debug builds of
        // OpenUSD. TF_DEV_AXIOM in Swift only evaluates the argument in debug
        // builds of Swift code that invokes it. (Notice that these are different.)
        // This macro needs to return an expression, but compiler directives
        // aren't expressions, so we need to create a closure so we have
        // a place to put `#if DEBUG`, and then call that closure so we
        // get the resulting Bool from calling `TF_VERIFY` or skipping it. 

        return """
        {
        #if DEBUG
        #TF_AXIOM(\(argument))
        #else
        true
        #endif
        }()
        """
    }
}


@main
struct MacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TF_VERIFY_Macro.self,
        TF_AXIOM_Macro.self,
        TF_DEV_AXIOM_Macro.self
    ]
}