//
//  RefcountingAcrossLanguages.h
//  swiftUsd
//
//  Created by Maddy Adams on 11/20/24.
//

#ifndef SWIFTUSD_CXXONLY_REFCOUNTINGACROSSLANGUAGES_H
#define SWIFTUSD_CXXONLY_REFCOUNTINGACROSSLANGUAGES_H

#include "pxr/base/tf/refPtr.h"
#include "pxr/base/tf/weakPtr.h"
#include "pxr/base/tf/retainReleaseHelper.h"
#include "swiftUsd/SwiftOverlay/SwiftCxxMacros.h"
#include <type_traits>

// Important: When C++ calls a Swift function and passes a shared reference
// as a function argument, Swift requires that C++ keep the value alive
// for the duration of the call to Swift.
// If PassToSwiftAsFunctionParameter is passed a TfRefPtr as a temporary value,
// this is unsafe, because the TfRefPtr will be destructed at the end of the
// statement that materializes it, rather at the end of scope, which would likely
// lead to a use-after-free.
// So, we want to force passing TfRefPtr pointees as function arguments to use
// local variables, by deleting the const-ref version, and only allowing the
// non-const ref version to be called.
// Returning TfRefPtr pointees from functions where the TfRefPtr is a temporary
// value is safe, and passing a TfWeakPtr as a temporary can be safe if
// someone else is retaining ownership, but because of how tricky working with
// shared reference types across the language boundary is,
// it's better to simply disallow temporary values altogether. 


namespace SwiftUsd {
    // Warn about discarding on PassToSwift, because they can manipulate the
    // ref count.
    // Intentionally use non-const ref to force non-temporary values. See comment at top of file

    template <class SmartPointer> [[nodiscard("Value must be returned to Swift")]]
    typename SmartPointer::DataType* _Nullable PassToSwiftAsReturnValue(SmartPointer& x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        // Swift expects return values to be at +1
        if (x) {
            pxr::Tf_RetainReleaseHelper::retain(x.operator->());
            return x.operator->();
        }
        return nullptr;
    }
    
    template <class SmartPointer> [[nodiscard("Value must be passed to Swift")]]
    typename SmartPointer::DataType* _Nullable PassToSwiftAsFunctionParameter(SmartPointer& x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        // Swift expects function parameters to be at +0
        // Don't just return x.operator->(), because that crashes on null
        return x ? x.operator->() : nullptr;
    }

    // static_assert in const-ref versions to force non-temporary values. See comment at top of file
    #ifndef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS
    
    template <class SmartPointer> [[nodiscard("Value must be returned to Swift, and may not be a temporary")]]
    typename SmartPointer::DataType* _Nullable PassToSwiftAsReturnValue(const SmartPointer& x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        static_assert(false, "PassToSwiftAsReturnValue may not be called with a temporary value. Pass a variable instead");
    }

    template <class SmartPointer> [[nodiscard("Value must be passed to Swift, and may not be a temporary")]]
    typename SmartPointer::DataType* _Nullable PassToSwiftAsFunctionParameter(const SmartPointer& x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.Dereference<T>(_:)") {
        static_assert(false, "PassToSwiftAsFunctionParameter may not be called with a temporary value. Pass a variable instead");
    }

    #endif /* ifndef OPENUSD_SWIFT_EMIT_SYMBOL_GRAPHS */

    // Don't warn about discarding on TakeFromSwift. The correct version
    // of one of these functions should be called whenever Swift returns
    // a SWIFT_SHARED_REFERENCE value to C++, to avoid memory leaks,
    // even if C++ wants to discard the Swift return value

    template <class SmartPointer>
    SmartPointer TakeReturnValueFromSwift(typename SmartPointer::DataType* _Nullable x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.TfRefPtr<T>(_:) or Overlay.TfWeakPtr<T>(_:)") {
        if constexpr (std::is_same_v<SmartPointer, pxr::TfRefPtr<typename SmartPointer::DataType>>) {
            // Swift returns at +1, so transfer that into a TfRefPtr.
            // `return pxr::TfRefPtr<typename SmartPointer::DataType>(x);` would leak because that TfRefPtr constructor does a retain
            return pxr::TfCreateRefPtr<typename SmartPointer::DataType>(x);
            
        } else if constexpr (std::is_same_v<SmartPointer, pxr::TfWeakPtr<typename SmartPointer::DataType>>) {
            // Swift returns at +1, so we need to do a release otherwise x will leak,
            // since the TfWeakPtr constructor doesn't take ownership
            pxr::TfWeakPtr<typename SmartPointer::DataType> result = pxr::TfWeakPtr<typename SmartPointer::DataType>(x);
            pxr::Tf_RetainReleaseHelper::release(x);
            return result;
            
        } else {
            static_assert(false, "TakeReturnValueFromSwift only supports TfRefPtr and TfWeakPtr return values");
        }
    }

    template <class SmartPointer>
    SmartPointer TakeFunctionParameterFromSwift(typename SmartPointer::DataType* _Nullable x)
    SWIFT_UNAVAILABLE_MESSAGE("Use Overlay.TfRefPtr<T>(_:) or Overlay.TfWeakPtr<T>(_:)") {
        if constexpr (std::is_same_v<SmartPointer, pxr::TfRefPtr<typename SmartPointer::DataType>>) {
            // Swift passes at +0
            // The TfRefPtr constructor does a retain, which will balance with ~TfRefPtr
            return pxr::TfRefPtr<typename SmartPointer::DataType>(x);

        } else if constexpr (std::is_same_v<SmartPointer, pxr::TfWeakPtr<typename SmartPointer::DataType>>) {
            // Swift passes at +0
            // The TfWeakPtr constructor doesn't retain
            return pxr::TfWeakPtr<typename SmartPointer::DataType>(x);

        } else {
            static_assert(false, "TakeFunctionParameterFromSwift only supports TfRefPtr and TfWeakPtr return values");
        }
    }
}

#endif /* SWIFTUSD_CXXONLY_REFCOUNTINGACROSSLANGUAGES_H */
