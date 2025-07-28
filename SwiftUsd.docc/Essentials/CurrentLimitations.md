# Current Limitations

Learn about the current limitations of OpenUSD in Swift

## Overview
OpenUSD in Swift is currently evolving and may change in the future. Here are some current limitations:

### Issues
- Swift compiler crashes  
**Workaround:** Prefer making incremental changes and recompile often to making large changes and recompiling infrequently

- `TfRefPtr.pointee` and `TfWeakPtr.pointee` are unavailable  
**Workaround:** Never use `.pointee`, always use [`Overlay.Dereference(_:)`](doc:OpenUSD/C++/Overlay/Dereference(_:)-67vpz)

- Nested `enum`s are not always imported ([https://github.com/swiftlang/swift/issues/62127](https://github.com/swiftlang/swift/issues/62127))  
**Workaround:** Use `Overlay.nested.enum` instead of `pxr.nested.enum`.  

- Autocomplete is slow to index  
**Workaround:** Refer to the [C++ API documentation](https://openusd.org/release/api/index.html)
I need to investigate `requires cplusplus` in the modulemap again.

- `UsdStage` cannot be passed to function expecting `TfWeakPtr<UsdStage>`  
**Workaround**: Manually construct and pass `Overlay.TfWeakPtr(stage)` instead

- `pxr.UsdGeomSphere.GetPrim()` is ambiguous when it shouldn't be (https://github.com/swiftlang/swift/pull/81709)
**Workaround:** Use `Overlay.GetPrim(_ s: UsdGeomSphere)` instead

- Some OpenUSD types are not imported  
**Workaround:** Write C++ code that wraps types you need to use from Swift. See `source/Wrappers` for examples.

- Some OpenUSD free friend functions (e.g. arithmetic for linear algebra) are not imported  
**Workaround:** Write your own free function



#### Highest priority
- [https://github.com/swiftlang/swift/pull/82333: [cxx-interop] Fix duplicate symbol error with default arguments](https://github.com/swiftlang/swift/pull/82333)  
**Workaround:** Pass default arguments explicitly when calling C++ functions



#### High priority
- [rdar://133777029: Cannot create std::function from Swift closures that capture context (thick closures)](rdar://133777029)
Impacts Linux, because TfNotice support has to use Objective-C blocks to convert thick Swift closures to `std::function`, and Linux doesn't really support that.

- [https://github.com/swiftlang/swift/issues/83081: Templated C++ function incorrectly imported as returning Void in Swift](https://github.com/swiftlang/swift/issues/83081)  
Hard to predict when it will occur, and annoying to workaround. (Making the return type void and adding an out-param usually works)

- [https://github.com/swiftlang/swift/issues/83117: Swift Array addition causes unrelated static_assert to fail](https://github.com/swiftlang/swift/issues/83117)  
Would allow simplifying the patch slightly, because it currently `#if !__swift__`'s out some `static_assert`'s that Swift erroneously triggers

- [rdar://150456875: Forward declaring std::map's value causes an error for Swift but not C++ (Swift 6.1 regression)](rdar://150456875)  
Would require simplifying the patch slightly

- [rdar://148534260: API notes should support annotating C++ operators](rdar://148534260)  
Would allow simplifying the patch a small amount. Requires [https://github.com/swiftlang/swift/issues/83118: API notes should support annotating templated C++ tags](https://github.com/swiftlang/swift/issues/83118) as well to simplify. 

- [https://github.com/swiftlang/swift/pull/82496: [cxx-interop] Allow import-as-member for types in namespaces](https://github.com/swiftlang/swift/pull/82496)  
Would simplify code generation without needing to make a typedef for the nested type

- [https://github.com/swiftlang/swift/pull/82566: [cxx-interop] Test import-as-member for inline functions](https://github.com/swiftlang/swift/pull/82566)  
Would simplify code generation and satisfying protocol requirements in C++

- [https://github.com/swiftlang/swift/pull/82579: [cxx-interop] Allow import-as-member for functions declared within a namespace](https://github.com/swiftlang/swift/pull/82579)  
Would make organizing import-as-member easier and avoid polluting the global namespace

- [https://github.com/swiftlang/swift/issues/83085: Calling friend function of type nested in C++ namespace crashes Swift compiler](https://github.com/swiftlang/swift/issues/83085)  
**Workaround:** Write a non-friend function that calls the friend, and call the non-friend from Swift

- [https://github.com/swiftlang/swift/issues/83144: SWIFT_NAME annotation has no effect on function templates](https://github.com/swiftlang/swift/issues/83144)  
Limits the ability to do import-as-member replacements

- [https://github.com/swiftlang/swift/issues/83148: Adding import CxxStdlib makes diagnostic about not enabling C++ interoperability harder to understand](https://github.com/swiftlang/swift/issues/83148)  
Without Swift-Cxx interop enabled, you get `Error: Cannot load underlying module for 'CxxStdlib'`


#### Medium priority

- [https://github.com/swiftlang/swift/issues/83115: Conforming C++ enum to Swift protocol causes linker errors (missing destructors for STL types)](https://github.com/swiftlang/swift/issues/83115)  
**Workaround:** Don't conform to protocols

- [https://github.com/swiftlang/swift/pull/82485: [cxx-interop] Allow virtual methods to be renamed with SWIFT_NAME](https://github.com/swiftlang/swift/pull/82485)  

- [https://github.com/swiftlang/swift/issues/83149: API Notes doesn't support renaming function overloads with different arities](https://github.com/swiftlang/swift/issues/83149)  
**Workaround:** Use `Availability: nonswift`, then import-as-member on new stubs that call the unavailable methods

- [https://github.com/swiftlang/swift/pull/82161: [cxx-interop] Import nullability of templated function parameters correctly](https://github.com/swiftlang/swift/pull/82161)  

- [https://github.com/swiftlang/swift/issues/83151: C++ struct holding std::vector<std::unique_ptr<int>> can't be used in Swift: get obscure template errors instead of being imported as ~Copyable](https://github.com/swiftlang/swift/issues/83151)  

- [https://github.com/swiftlang/swift/issues/83152: Add support for default arguments in C++ function templates](https://github.com/swiftlang/swift/issues/83152)  

- [https://github.com/swiftlang/swift/issues/83153: Add support for importing operator function templates from C++](https://github.com/swiftlang/swift/issues/83153)

- [https://github.com/swiftlang/swift/issues/83154: Add a way to extract elements from std::tuple in Swift](https://github.com/swiftlang/swift/issues/83154)  

- [rdar://149496877: std::map, unordered_map should conform to Sequence](rdar://149496877)  

- [rdar://153678715: std::vector<T> should conform to Codable when T does](rdar://153678715)  

- [rdar://121886233: Support specializing class templates with concrete types using <> syntax](rdar://121886233)  
Can't use `pxr.VtArray<pxr.GfVec3f>` or `std.set<std.string>` in Swift. Workaround of using a C++ typedef works but is annoying

#### Low priority

- [https://github.com/swiftlang/swift/issues/83155: Add support for std::ostream in Swift](https://github.com/swiftlang/swift/issues/83155)  

- [https://github.com/swiftlang/swift/issues/83114: Inherited methods from non-imported C++ types aren't available on imported types](https://github.com/swiftlang/swift/issues/83114)

- [https://github.com/swiftlang/swift/issues/62127: C++ interop: nested `enum` not imported](https://github.com/swiftlang/swift/issues/62127)  
Worked around in Swift Package by automatically wrapping all public enums from Usd, by introspecting the Clang AST.

- [rdar://138359065: 'pxr.UsdStage' is not a member of type '\_\_ObjC.pxr'; public typealias not used in typenames, only statements)](rdar://138359065)  
Workaround involves putting a typealias in downstream client projects. Not the worst, but not at all intuitive, especially since it only breaks for typenames.

- [https://github.com/swiftlang/swift/issues/83079: Templated overload causes substitution failure in Swift but not in C++ (SFINAE)](https://github.com/swiftlang/swift/issues/83079)  
Easy to wrap function in Swift Package

- [rdar://132742486: Function returning C++ type in namespace is `inaccessible due to '@_spi'` when it isn't marked SPI](rdar://132742486))  
Doesn't currently impact OpenUSD because I'm not adding free functions that return Usd types. But if I wanted to add free functions that return Usd types, this would be a blocker.

- [https://github.com/swiftlang/swift/issues/83118: API notes should support annotating templated C++ tags](https://github.com/swiftlang/swift/issues/83118)  
This could enable me to use API notes to succinctly conform all specializations of `pxr::VtArray<T>` to `Sequence` and `ExpressibleByArrayLiteral`


- [https://github.com/swiftlang/swift/issues/83078: Calling __convertToBool() from Swift on derived C++ value type crashes](https://github.com/swiftlang/swift/issues/83078)  
Can be replaced with a `Bool.init(UsdGeomSphere)` supplied by this repo, which is also more ergonomic


- [https://github.com/swiftlang/swift/issues/83114: Inherited methods from non-imported classes aren't available on imported types](https://github.com/swiftlang/swift/issues/83114)  
Would be helpful for SwiftUsd in a few niche places.

- [https://github.com/swiftlang/swift/issues/83077: Linker error when accessing C++ constant static member from Swift](https://github.com/swiftlang/swift/issues/83077)  
Easy workaround

- [https://github.com/swiftlang/swift/issues/83080: Assigning a non-nil value to a weak SWIFT_SHARED_REFERENCE variable crashes at runtime](https://github.com/swiftlang/swift/issues/83080)  

- [rdar://138118008: Spurious "warning: cycle detected while resolving" message (Usd interop)](rdar://138118008)  
Spurious warning that occurs in a few places when building the Swift Package. Seems harmless. 

- [rdar://137880350: `pxr.UsdGeomTokens` crashes Swift compiler](rdar://137880350)  
People might try to write this expression in OpenUSD, but I've provided wrappers for most of the cases something like this would occur. 

- [rdar://137879510: SdfValueTypeName does not automatically conform to CxxConvertibleToBool](rdar://137879510)  
Can be worked around by calling `__convertToBool()`. I can probably put `extension pxr.SdfValueTypeName: CxxConvertibleToBool {}` in the Swift Package, or add an initializer on `Bool`. 

- [https://github.com/swiftlang/swift/pull/81709: [cxx-interop] Fix ambiguous methods in long chains of inheritance](https://github.com/swiftlang/swift/pull/81709)  
Easy workaround in C++, but annoying to have to use everywhere.  
I can improve the workaround by using `SWIFT_NAME` on the base class's declaration of `GetPrim` to hide that method from Swift, then extend each subclass to add a Swift method named `GetPrim()` that calls a C++ helper method that calls the base class's definition of `GetPrim`. 

- [https://github.com/swiftlang/swift/issues/83146: Calling free function template with SWIFT_NAME + import-as-member as free function crashes compiler](https://github.com/swiftlang/swift/issues/83146)  
Limits the ability to do import-as-member replacements
