//
//  SwiftOverlay_FRTProtocols.swift
//
//
//  Created by Maddy Adams on 11/18/24.
//

import Foundation

// MARK: SwiftUsdReferenceTypeProtocol definition

extension Overlay {
    /// Protocol representing all foreign reference types in OpenUSD. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _SwiftUsdReferenceTypeProtocol: Equatable, Hashable, Comparable {
        /// A stand-in for `Self` that works around a compiler crash involving non-final FRT casting
        associatedtype _SelfType
        
        /// The address of the reference type
        var _address: UnsafeMutableRawPointer { get }
    }
}

extension Overlay {
   /// Protocol representing immortal reference types in OpenUSD. Don't use this unless you know what you're doing
   @_documentation(visibility: public)
   public protocol _SwiftUsdImmortalReferenceTypeProtocol: _SwiftUsdReferenceTypeProtocol {
   }
}

// MARK: TfRefBaseProtocol, TfRefPtrProtocol definition

extension Overlay {
    /// Protocol representing `pxr::TfRefBase` subclasses. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfRefBaseProtocol: _SwiftUsdReferenceTypeProtocol where _SelfType: _TfRefBaseProtocol {
        /// The type of `pxr::TfRefPtr<Self>`
        associatedtype _TfRefPtrType: Overlay._TfRefPtrProtocol where _TfRefPtrType._TfRefBaseType == _SelfType
        /// The type of `pxr::TfRefPtr<const Self>`
        associatedtype _TfConstRefPtrType: Overlay._TfConstRefPtrProtocol where _TfConstRefPtrType._TfRefBaseType == _SelfType
        
        /// Wraps `self` in a `pxr::TfRefPtr`
        func _asRefPtrType() -> _TfRefPtrType
        /// Dereferences the `pxr::TfRefPtr`, returning either `Self` or nil
        static func _fromRefPtrType(_ p: _TfRefPtrType) -> _SelfType?
        /// Dereferences the `pxr::TfRefPtr`, returning either `Self` or nil
        static func _fromConstRefPtrType(_ p: _TfConstRefPtrType) -> _SelfType?

        /// Performs a dynamic cast from the raw pointer
        static func _fromRawPointer(_ p: UnsafeMutableRawPointer?) -> _SelfType?
    }

    /// Protocol representing `pxr::TfRefPtr<T>` specializations. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfRefPtrProtocol {
        /// The type of `T`
        associatedtype _TfRefBaseType: Overlay._TfRefBaseProtocol where _TfRefBaseType._TfRefPtrType == Self
        /// Returns a `Self` pointing to null
        static func _nullPtr() -> Self
        /// Returns `true` if `self` is not pointing to null
        func _isNonnull() -> Bool
    }

    /// Protocol representing `pxr::TfRefPtr<const T>` specializations. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfConstRefPtrProtocol {
        /// The type of `T`, without const qualification
        associatedtype _TfRefBaseType: Overlay._TfRefBaseProtocol where _TfRefBaseType._TfConstRefPtrType == Self
        /// Returns `true` is `self` is not pointing to null
        func _isNonnull() -> Bool
    }
}

// MARK: TfWeakBaseProtocol, TfWeakPtrProtocol definition

extension Overlay {
    /// Protocol representing `pxr::TfWeakBase` subclasses. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfWeakBaseProtocol: _SwiftUsdReferenceTypeProtocol where _SelfType: _TfWeakBaseProtocol {
        /// The type of `pxr::TfWeakPtr<Self>`
        associatedtype _TfWeakPtrType: Overlay._TfWeakPtrProtocol where _TfWeakPtrType._TfWeakBaseType == _SelfType
        /// The type of `pxr::TfWeakPtr<const Self>`
        associatedtype _TfConstWeakPtrType: Overlay._TfConstWeakPtrProtocol where _TfConstWeakPtrType._TfWeakBaseType == _SelfType
        
        /// Wraps `self` in a `pxr::TfWeakPtr`
        func _asWeakPtrType() -> _TfWeakPtrType
        /// Dereferences the `pxr::TfWeakPtr`, returning either `Self` or nil
        static func _fromWeakPtrType(_ p: _TfWeakPtrType) -> _SelfType?
        /// Dereferences the `pxr::TfWeakPtr`, returning either `Self` or nil
        static func _fromConstWeakPtrType(_ p: _TfConstWeakPtrType) -> _SelfType?
    }

    /// Protocol representing `pxr::TfWeakPtr<T>` specializations. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfWeakPtrProtocol {
        /// The type of `T`
        associatedtype _TfWeakBaseType: Overlay._TfWeakBaseProtocol where _TfWeakBaseType._TfWeakPtrType == Self
        /// Converts `self` to a `pxr::TfAnyWeakPtr`
        func _asAnyWeakPtr() -> pxr.TfAnyWeakPtr
        /// Converts the argument to `Self`, which may be null if dynamic casting failed
        static func _fromAnyWeakPtr(_ p: pxr.TfAnyWeakPtr) -> Self
        /// Returns a `Self` pointing to null
        static func _nullPtr() -> Self
        /// Returns `true` if `self` is not pointing to null
        func _isNonnull() -> Bool
    }

    /// Protocol representing `pxr::TfWeakPtr<const T>` specializations. Don't use this unless you know what you're doing
    @_documentation(visibility: public)
    public protocol _TfConstWeakPtrProtocol {
        /// The type of `T`, without const qualification
        associatedtype _TfWeakBaseType: Overlay._TfWeakBaseProtocol where _TfWeakBaseType._TfConstWeakPtrType == Self
        /// Returns `true` is `self` is not pointing to null
        func _isNonnull() -> Bool
    }
}

extension Overlay {
    /// Holds a `pxr::TfWeakBase` subclass weakly
    @_documentation(visibility: public)
    public struct WeakReferenceHolder<T: Overlay._TfWeakBaseProtocol>: Equatable, Hashable, Comparable where T._SelfType == T {
        /// Holds the argument weakly
        public init(value: T?) {
            _storage = Overlay.TfWeakPtr(value)
        }

        /// Backing storage
        internal var _storage: T._TfWeakPtrType

        /// The value being held weakly
        public var value: T? {
            get {
                Overlay.DereferenceOrNil(_storage)
            } set {
                _storage = Overlay.TfWeakPtr(newValue)
            }
        }

        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.value == rhs.value
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }

        public static func <(lhs: Self, rhs: Self) -> Bool {
            switch (lhs.value, rhs.value) {
                case let (.some(l), .some(r)): return l < r
                case (nil, nil): return false
                default: return lhs.value == nil
            }
        }
    }
}


// MARK: Pointer conversion functions
extension Overlay {
    /// Dereferences a `pxr::TfRefPtr<T>`. Crashes if the pointer is null
    public static func Dereference<T>(_ x: T) -> T._TfRefBaseType where T: Overlay._TfRefPtrProtocol { Overlay.DereferenceOrNil(x)! }
    /// Dereferences a `pxr::TfWeakPtr<T>`. Crashes if the pointer is null
    public static func Dereference<T>(_ x: T) -> T._TfWeakBaseType where T: Overlay._TfWeakPtrProtocol { Overlay.DereferenceOrNil(x)! }
    /// Dereferences a `pxr::TfAnyWeakPtr`. Crashes if the pointer is null or dynamic casting fails
    internal static func _Dereference<T>(_ x: pxr.TfAnyWeakPtr, as: T.Type) -> T where T: Overlay._TfWeakBaseProtocol, T._SelfType == T { Overlay._DereferenceOrNil(x, as: T.self)! }
    /// Dereferences a `pxr::TfRefPtr<const T>`. Crashes if the pointer is null
    public static func Dereference<T>(_ x: T) -> T._TfRefBaseType where T: Overlay._TfConstRefPtrProtocol { Overlay.DereferenceOrNil(x)! }
    /// Dereferences a `pxr::TfWeakPtr<const T>`. Crashes if the pointer is null
    public static func Dereference<T>(_ x: T) -> T._TfWeakBaseType where T: Overlay._TfConstWeakPtrProtocol { Overlay.DereferenceOrNil(x)! }
    
    /// Dereferences a `pxr::TfRefPtr<T>`, returning either `T` or `nil`
    public static func DereferenceOrNil<T>(_ x: T) -> T._TfRefBaseType? where T: Overlay._TfRefPtrProtocol { T._TfRefBaseType._fromRefPtrType(x) }
    /// Dereferences a `pxr::TfWeakPtr<T>`, returning either `T` (held strongly) or `nil`
    public static func DereferenceOrNil<T>(_ x: T) -> T._TfWeakBaseType? where T: Overlay._TfWeakPtrProtocol { T._TfWeakBaseType._fromWeakPtrType(x) }
    /// Dereferences a `pxr::TfAnyWeakPtr`, returning either `T` or `nil`. Returns `nil` if dynamic casting fails
    internal static func _DereferenceOrNil<T>(_ x: pxr.TfAnyWeakPtr, as: T.Type) -> T? where T: Overlay._TfWeakBaseProtocol, T._SelfType == T { Overlay.DereferenceOrNil(Overlay._TfWeakPtr(x, pointingTo: T.self)) }
    /// Dereferences a `pxr::TfRefPtr<const T>`, returning either `T` (without const qualification) or `nil`
    public static func DereferenceOrNil<T>(_ x: T) -> T._TfRefBaseType? where T: Overlay._TfConstRefPtrProtocol { T._TfRefBaseType._fromConstRefPtrType(x) }
    /// Dereferences a `pxr::TfWeakPtr<const T>`, returning either `T` (without const qualification) or `nil`
    public static func DereferenceOrNil<T>(_ x: T) -> T._TfWeakBaseType? where T: Overlay._TfConstWeakPtrProtocol { T._TfWeakBaseType._fromConstWeakPtrType(x) }

    /// Wraps the argument in a `pxr::TfRefPtr<T>`
    public static func TfRefPtr<T>(_ x: T?) -> T._TfRefPtrType where T: Overlay._TfRefBaseProtocol { x?._asRefPtrType() ?? ._nullPtr() }
    /// Wraps the argument in a `pxr::TfRefPtr<T>`
    // Disfavored overload to allow for passing nil as a literal in limited type inference contexts
    @_disfavoredOverload
    public static func TfRefPtr<T>(_ x: T._TfRefBaseType?) -> T where T: Overlay._TfRefPtrProtocol { x?._asRefPtrType() ?? ._nullPtr() }
    /// Converts a `pxr::TfWeakPtr<T>` into a `pxr::TfRefPtr<T>`
    public static func TfRefPtr<T>(_ x: T) -> T._TfWeakBaseType._TfRefPtrType where T: Overlay._TfWeakPtrProtocol, T._TfWeakBaseType: Overlay._TfRefBaseProtocol { Overlay.TfRefPtr(Overlay.DereferenceOrNil(x)) }
    /// Converts a `pxr::TfAnyWeakPtr` into a `pxr::TfRefPtr<T>`
    internal static func _TfRefPtr<T>(_ x: pxr.TfAnyWeakPtr, pointingTo: T.Type) -> T._TfRefPtrType where T: Overlay._TfRefBaseProtocol & Overlay._TfWeakBaseProtocol, T._SelfType == T { Overlay.TfRefPtr(Overlay._DereferenceOrNil(x, as: T.self)) }

    /// Wraps the argument in a `pxr::TfWeakPtr<T>`
    public static func TfWeakPtr<T>(_ x: T?) -> T._TfWeakPtrType where T: Overlay._TfWeakBaseProtocol { x?._asWeakPtrType() ?? ._nullPtr() }
    /// Wraps the argument in a `pxr::TfWeakPtr<T>`
    // Disfavored overload to allow for passing nil as a literal in limited type inference contexts
    @_disfavoredOverload
    public static func TfWeakPtr<T>(_ x: T._TfWeakBaseType?) -> T where T: Overlay._TfWeakPtrProtocol { x?._asWeakPtrType() ?? ._nullPtr() }
    /// Converts a `pxr::TfRefPtr<T>` into a `pxr::TfWeakPtr<T>`
    public static func TfWeakPtr<T>(_ x: T) -> T._TfRefBaseType._TfWeakPtrType where T: Overlay._TfRefPtrProtocol, T._TfRefBaseType: Overlay._TfWeakBaseProtocol { Overlay.TfWeakPtr(Overlay.DereferenceOrNil(x)) }
    /// Converts a `pxr::TfAnyWeakPtr` into a `pxr::TfWeakPtr<T>`
    internal static func _TfWeakPtr<T>(_ x: pxr.TfAnyWeakPtr, pointingTo: T.Type) -> T._TfWeakPtrType where T: Overlay._TfWeakBaseProtocol { T._TfWeakPtrType._fromAnyWeakPtr(x) }
    
    /// Wraps the argument in a `pxr::TfAnyWeakPtr`
    internal static func _TfAnyWeakPtr<T>(_ x: T?) -> pxr.TfAnyWeakPtr where T: Overlay._TfWeakBaseProtocol { Overlay._TfAnyWeakPtr(Overlay.TfWeakPtr(x)) }
    /// Converts a `pxr::TfRefPtr<T>` into a `pxr::TfAnyWeakPtr`
    internal static func _TfAnyWeakPtr<T>(_ x: T) -> pxr.TfAnyWeakPtr where T: Overlay._TfRefPtrProtocol, T._TfRefBaseType: Overlay._TfWeakBaseProtocol { Overlay._TfAnyWeakPtr(Overlay.TfWeakPtr(x)) }
    /// Converts a `pxr::TfWeakPtr<T>` into a `pxr::TfAnyWeakPtr`
    internal static func _TfAnyWeakPtr<T>(_ x: T) -> pxr.TfAnyWeakPtr where T: Overlay._TfWeakPtrProtocol { x._asAnyWeakPtr() }
}

// MARK: Protocol default implementations

public func ===<T: Overlay._SwiftUsdReferenceTypeProtocol>(lhs: T?, rhs: T?) -> Bool {
    lhs?._address == rhs?._address
}
public func !==<T: Overlay._SwiftUsdReferenceTypeProtocol>(lhs: T?, rhs: T?) -> Bool {
    !(lhs === rhs)
}

extension Overlay._SwiftUsdReferenceTypeProtocol {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs._address == rhs._address
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_address)
    }
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs._address < rhs._address
    }
}

extension Bool {
    /// Returns `true` if the pointer is not null
    public init(_ p: some Overlay._TfRefPtrProtocol) {
        self.init(p._isNonnull())
    }
    /// Returns `true` if the pointer is not null.
    public init(_ p: some Overlay._TfWeakPtrProtocol) {
        self.init(p._isNonnull())
    }
    /// Returns `true` if the pointer is not null
    public init(_ p: some Overlay._TfConstRefPtrProtocol) {
        self.init(p._isNonnull())
    }
    /// Returns `true` if the pointer is not null.
    public init(_ p: some Overlay._TfConstWeakPtrProtocol) {
        self.init(p._isNonnull())
    }
}

extension Overlay._TfRefBaseProtocol {
    /// Dynamically casts `self` to the argument type.
    ///
    /// In Swift 6.0, the built-in `as/as?/as!` operators don't work properly on foreign reference types.
    /// Instead, use this function to conditionally cast between subclasses of `pxr::TfRefBase`
    public func `as`<T: Overlay._TfRefBaseProtocol>(_ t: T.Type = T.self) -> T? where T._SelfType == T {
        T._fromRawPointer(_address)
    }
}

// MARK: Special case TfRefBase
// TfRefPtr<TfRefBase> is not a supported template, so we handle
// the conformance manually. (We want TfRefBase to be supported
// so there's more fluency with casting and testing casting,
// for example)
extension pxr.TfRefBase: Overlay._TfRefBaseProtocol {
    public typealias _TfRefPtrType = Never
    public typealias _TfConstRefPtrType = Never
    public func _asRefPtrType() -> Never { fatalError("pxr.TfRefBase is not convertible to pxr.TfRefPtr") }
    public static func _fromRefPtrType(_ p: Never) -> pxr.TfRefBase? {}
    public static func _fromConstRefPtrType(_ p: Never) -> pxr.TfRefBase? {}
}
extension Never: Overlay._TfRefPtrProtocol, Overlay._TfConstRefPtrProtocol {
    public typealias _TfRefBaseType = pxr.TfRefBase
    public static func _nullPtr() -> Never { fatalError("pxr.TfRefBase has no TfRefPtr nullptr value") }
    public func _isNonnull() -> Bool { fatalError("pxr.TfRefBase has no TfRefPtr type") }    
}

extension Overlay._TfRefPtrProtocol {
    @_documentation(visibility: internal)
    @available(*, unavailable, message: "`.pointee` is unsafe; use Overlay.Dereference(_:) instead")
    public var pointee: _TfRefBaseType { fatalError() }
}
extension Overlay._TfWeakPtrProtocol {
    @_documentation(visibility: internal)
    @available(*, unavailable, message: "`.pointee` is unsafe; use Overlay.Dereference(_:) instead")
    public var pointee: _TfWeakBaseType { fatalError() }
}
extension Overlay._TfConstRefPtrProtocol {
    @_documentation(visibility: internal)
    @available(*, unavailable, message: "`.pointee` is unsafe; use Overlay.Dereference(_:) instead")
    public var pointee: _TfRefBaseType { fatalError() }
}
extension Overlay._TfConstWeakPtrProtocol {
    @_documentation(visibility: internal)
    @available(*, unavailable, message: "`.pointee` is unsafe; use Overlay.Dereference(_:) instead")
    public var pointee: _TfWeakBaseType { fatalError() }
}