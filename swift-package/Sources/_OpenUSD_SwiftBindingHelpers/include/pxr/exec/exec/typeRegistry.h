//
// Copyright 2025 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_EXEC_EXEC_TYPE_REGISTRY_H
#define PXR_EXEC_EXEC_TYPE_REGISTRY_H

/// \file

#include "pxr/pxr.h"

#include "pxr/exec/exec/api.h"
#include "pxr/exec/exec/valueExtractorFunction.h"

#include "pxr/exec/vdf/executionTypeRegistry.h"
#include "pxr/exec/vdf/mask.h"
#include "pxr/exec/vdf/typeDispatchTable.h"
#include "pxr/exec/vdf/vector.h"

#include "pxr/base/tf/refPtr.h"
#include "pxr/base/tf/singleton.h"
#include "pxr/base/tf/type.h"
#include "pxr/base/vt/array.h"
#include "pxr/base/vt/traits.h"
#include "pxr/base/vt/types.h"
#include "pxr/base/vt/value.h"

#include <tbb/concurrent_unordered_map.h>

#include <algorithm>
#include <memory>
#include <type_traits>

PXR_NAMESPACE_OPEN_SCOPE

class Exec_ValueExtractor;
class VdfMask;

/// Singleton used to register and access value types used by exec computations.
///
/// Value types that are used for exec computation input and output values must
/// be registered with this registry.
///
/// The registry is initialized with all value types that Sdf suports for
/// attribute and metadata values.
///
class ExecTypeRegistry
{
public:
    ExecTypeRegistry(ExecTypeRegistry const&) = delete;
    ExecTypeRegistry& operator=(ExecTypeRegistry const&) = delete;

    ~ExecTypeRegistry();

    /// Provides access to the singleton instance, first ensuring it is
    /// constructed.
    ///
    EXEC_API
    static const ExecTypeRegistry &GetInstance();

    /// Registers \p ValueType as a type that exec computations can use for
    /// input and output values, with the fallback value \p fallback.
    ///
    /// In any circumstance that requires an arbitrary value of type \p
    /// ValueType must be produced, \p fallback will be used.
    ///
    /// All types that can be used to author attribute and metadata values in
    /// USD are available as exec value types by default. User-defined types
    /// must be registered using this function.
    ///
    /// \warning
    /// If a given \p ValueType is registered more than once, all calls must
    /// specify the same \p fallback; the equality operator for the type is used
    /// to verify that all fallback values have the same value.
    ///
    /// # Value Type Requirements
    ///
    /// Values produced by computations will, in general, be copied, cached, and
    /// made available to computation callbacks that are evaluated in
    /// parallel. Therefore, care must be taken when choosing exec value
    /// types. Types that strictly obey value semantics are safe to use as exec
    /// value types and it is preferable to use such types whenever possible.
    ///
    /// When computations produce large data that would be inefficient to copy,
    /// it is appealing to have the computation return a pointer. But many
    /// pointer types are not safe to use as exec value types: Parallel
    /// evalution makes it unsafe for computation callbacks to mutate pointed-to
    /// data. Additionally, doing so could modify data that is held in a cache,
    /// which would thwart the exec system's ability to correctly invalidate
    /// caches. Therefore, pointer types are generally unsafe to use, other than
    /// strong shared references to const data. In particular,
    /// `std::shared_ptr<const T>` and `TfRefPtr<const T>` are recommended for
    /// use as exec value types, when a pointer type is required. (Though using
    /// these types doesn't, of course, guaranty safety, since the pointed-to
    /// type could have const methods that mutate data, etc.)
    ///
    /// \note
    /// - Exec value types must be copyable, as mentioned above.
    /// - Exec value types must also be equality comparable, e.g., so that we
    ///   can compare fallback values to ensure that multiple registrations are
    ///   consistent (as mentioned above).
    ///
    /// # Example
    ///
    /// ```cpp
    /// struct CustomType {
    ///     int i;
    ///     std::string s;
    /// 
    ///     friend
    ///     bool operator==(const CustomType &a, const CustomType &b) {
    ///         return a.i == b.i && a.s == b.s;
    ///     }
    /// };
    /// 
    /// TF_REGISTRY_FUNCTION(ExecTypeRegistry)
    /// {
    ///     ExecTypeRegistry::RegisterType(CustomType{});
    /// }
    /// ```
    ///
    template <typename ValueType>
    static void RegisterType(const ValueType &fallback);

    /// Confirms that \p ValueType has been registered.
    ///
    /// If \p ValueType has been registered with the ExecTypeRegistry, the
    /// corresponding TfType is returned.
    ///
    /// \warning
    /// If \p ValueType has not been registerd, a fatal error is emitted.
    ///
    template <typename ValueType>
    TfType CheckForRegistration() const {
        return VdfExecutionTypeRegistry::CheckForRegistration<ValueType>(
            "Use ExecTypeRegistry::RegisterType<T>() to register execution "
            "value types.");
    }

    /// Construct a VdfVector whose value is copied from \p value.
    EXEC_API
    VdfVector CreateVector(const VtValue &value) const;

    /// Returns an extractor that produces a VtValue from values held in
    /// execution.
    /// 
    /// Note that \p type is the type that should be held in the VtValue
    /// extraction result.  This is distinct from the execution data-flow
    /// type.
    ///
    EXEC_API
    Exec_ValueExtractor GetExtractor(TfType type) const;

private:
    // Only TfSingleton can create instances.
    friend class TfSingleton<ExecTypeRegistry>;

    // Provides access for registraion of types only.
    EXEC_API
    static ExecTypeRegistry& _GetInstanceForRegistration();

    ExecTypeRegistry();

    template <typename ValueType>
    void _RegisterType(ValueType const &fallback);

    template <typename T>
    struct _CreateVector {
        // Interface for VdfTypeDispatchTable.
        static VdfVector Call(const VtValue &value) {
            return Create(value.UncheckedGet<T>());
        }
        // Typed implementation of CreateVector.
        //
        // This is separate from Call so that it can be shared with the
        // Vt known type optimization in CreateVector.
        static VdfVector Create(const T &value);
    };

    // Returns the appropriate value extractor for T.
    //
    // When T is a VtArray type, the returned extractor expects a VdfVector
    // holding T::value_type elements as its input.
    //
    template <typename T>
    static auto _MakeExtractorFunction();

    // Specify that values of \p type should be extracted using \p function.
    EXEC_API
    void _RegisterExtractor(
        TfType type,
        Exec_ValueExtractorFunction &extractor);

    // Type trait that evaluates to true if T is a pointer type that is safe to
    // use as an exec value type, but that points to non-const data (which is
    // not safe).
    //
    // This isn't intended to be a general purpose trait, and it isn't intended
    // to guarantee that unsafe pointer types can't be used as value types. This
    // is used to provide compile time feedback for _some_ pointer types that
    // aren't / safe to use as exec value types.
    //
    // Note that many pointer types are disallowed regardless of the type they
    // point to for other reasons (e.g., std::unique_ptr isn't copyable and
    // std::weak_ptr doesn't support equality comparison).
    //
    // TODO: We should be able to use inline constexpr variable templates, but
    // gcc 11.5 incorrectly rejects class-scope partial specializations:
    // https://gcc.gnu.org/bugzilla/show_bug.cgi?id=71954

    template <typename T>
    struct _IsPointerToNonConst : std::false_type {};

    template <typename T>
    struct _IsPointerToNonConst<std::shared_ptr<T>> :
        std::negation<std::is_const<T>> {};

    template <typename T>
    struct _IsPointerToNonConst<TfRefPtr<T>> :
        std::negation<std::is_const<T>> {};

private:

    VdfTypeDispatchTable<_CreateVector> _createVector;

    // Type-erased conversions from VdfVector to VtValue.
    //
    // Inside of execution, there is no distinction between a scalar value and
    // an array value of length 1.  However, systems that interact with
    // execution may desire single values be returned directly in VtValue or
    // as a VtValue holding a VtArray depending on the context.  The type key
    // specifies the type held in the resulting VtValue.  There are separate
    // extractors for T and VtArray<T> but they both accepts VdfVectors
    // holding T.
    //
    // Note that this must support the possibility that one thread is querying
    // extractors at the same time that another thread is registering
    // additional types.
    //
    tbb::concurrent_unordered_map<TfType, Exec_ValueExtractor, TfHash>
        _extractors;
};

template <typename ValueType>
void
ExecTypeRegistry::RegisterType(const ValueType &fallback)
{
    using T = std::decay_t<ValueType>;
    static_assert(
        std::is_copy_constructible_v<T> && std::is_copy_assignable_v<T>,
        "Execution value types must be copyable.");
    static_assert(
        VdfIsEqualityComparable<T>,
        "Execution value types must support equality comparison.");
    static_assert(
        !std::is_pointer_v<T>,
        "Raw pointers are not supported execution value types.");
    static_assert(
        !_IsPointerToNonConst<T>::value,
        "Pointers to non-const data are not supported execution value "
        "types.");
    static_assert(
        !VtIsArray<T>::value,
        "VtArray is not a supported execution value type.");

    _GetInstanceForRegistration()._RegisterType(fallback);
}

template <typename ValueType>
void
ExecTypeRegistry::_RegisterType(ValueType const &fallback)
{
    const TfType type = VdfExecutionTypeRegistry::Define(fallback);

    // CreateVector has internal handling for value types known to Vt so we do
    // not need to register them here.
    if constexpr (!VtIsKnownValueType<ValueType>()) {
        _createVector.RegisterType<ValueType>();
    }

    _RegisterExtractor(type, *+_MakeExtractorFunction<ValueType>());
}

template <typename T>
VdfVector
ExecTypeRegistry::_CreateVector<T>::Create(const T &value)
{
    if constexpr (!VtIsArray<T>::value) {
        VdfVector v = VdfTypedVector<T>();
        v.Set(value);
        return v;
    }
    else {
        using ElementType = typename T::value_type;

        const size_t size = value.size();

        Vdf_BoxedContainer<ElementType> execValue(size);
        std::copy_n(value.cdata(), size, execValue.data());

        VdfVector v = VdfTypedVector<ElementType>();
        v.Set(std::move(execValue));
        return v;
    }
}

template <typename T>
auto
ExecTypeRegistry::_MakeExtractorFunction()
{
    if constexpr (!VtIsArray<T>::value) {
        return [](const VdfVector &v, const VdfMask::Bits &mask) {
            const VdfVector::ReadAccessor access =
                v.GetReadAccessor<T>();

            if (access.IsEmpty()) {
                return VtValue();
            }

            if (!TF_VERIFY(mask.GetNumSet() == 1)) {
                return VtValue();
            }

            const int offset = mask.GetFirstSet();
            return VtValue(access[offset]);
        };
    }
    else {
        return [](const VdfVector &v, const VdfMask::Bits &mask) {
            using ElementType = typename T::value_type;

            if (!TF_VERIFY(mask.AreContiguouslySet())) {
                return VtValue();
            }

            const VdfVector::ReadAccessor access =
                v.GetReadAccessor<ElementType>();

            const int offset = mask.GetFirstSet();
            const size_t numValues = access.IsBoxed()
                ? access.GetNumValues()
                : mask.GetNumSet();
            return VtValue(v.ExtractAsVtArray<ElementType>(numValues, offset));
        };
    }
}

PXR_NAMESPACE_CLOSE_SCOPE

#endif
