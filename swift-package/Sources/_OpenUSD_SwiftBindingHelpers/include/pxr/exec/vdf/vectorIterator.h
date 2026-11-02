//
// Copyright 2026 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_EXEC_VDF_VECTOR_ITERATOR_H
#define PXR_EXEC_VDF_VECTOR_ITERATOR_H

#include "pxr/pxr.h"

#include "pxr/exec/vdf/api.h"
#include "pxr/exec/vdf/boxedContainer.h"
#include "pxr/exec/vdf/compressedIndexMapping.h"
#include "pxr/exec/vdf/vectorData.h"

#include <cstddef>

PXR_NAMESPACE_OPEN_SCOPE

/// A read-only iterator over values held by a VdfVector.
///
template <typename T>
class VdfVectorIterator
{
public:
    /// Construct an iterator that is at end and not associated with a vector.
    VdfVectorIterator() = default;

    // Copyability is not provided because it is not currently required by
    // clients.  It would be non-trivial due to the potentially self-referential
    // _mapping pointer.
    VdfVectorIterator(const VdfVectorIterator&) = delete;
    VdfVectorIterator& operator=(const VdfVectorIterator&) = delete;

    /// Returns `true` if this does not point to an element in the vector.
    bool IsAtEnd() const {
        const size_t dataEndIndex = _end - _begin;
        return _dataIndex == dataEndIndex;
    }

    /// Advances the iterator to the next data element.
    VdfVectorIterator& operator++();

    /// Returns the data element pointed to by this.
    const T& operator*() const {
        TF_DEV_AXIOM(!IsAtEnd());
        return _begin[_dataIndex];
    }

    /// Advances this to a data element at or past `idx`.
    ///
    /// Returns `true` if this points exactly at `idx` after advancing.  Because
    /// compressed vectors have gaps in their indices, a `false` return value
    /// indicates that the iterator advanced past `idx`, without necessarily
    /// having advanced to the end.
    ///
    /// As an example, the following code copies every 5th data element if it
    /// exists in the source vector:
    ///
    /// ```{.cpp}
    /// VdfVectorIterator<T> it = vector.GetIterator<T>();
    /// std::vector<T> result;
    /// for (size_t i=0; !it.IsAtEnd(); i+=5) {
    ///     if (it.AdvanceTo(i)) {
    ///         result.push_back(*it);
    ///     }
    /// }
    /// ```
    ///
    bool AdvanceTo(size_t idx);

private:
    friend class VdfVector;

    explicit VdfVectorIterator(const Vdf_VectorData::Info& info);

    // Returns the index of the current data element.
    size_t _GetIndex() const {
        return _mapping->logicalStartIndex + _logicalOffset;
    }

private:
    // Offset from _begin of the current data element.
    size_t _dataIndex = 0;
    // Offset from _mapping->logicalStartIndex of the current data element.
    size_t _logicalOffset = 0;
    // Maps between logical and data indices in the current block.  Points to
    // _localMapping when iterating a non-compressed vector.
    const Vdf_IndexBlockMapping *_mapping = nullptr;

    // Semi-open range over all data elements stored by the vector.
    const T *_begin = nullptr;
    const T *_end = nullptr;
    // Only vectors with a compressed layout, which are rare, have block
    // mappings.  For all other layouts, use a single block mapping that covers
    // the entire range.
    Vdf_IndexBlockMapping _localMapping = { 0, 0 };
};

template <typename T>
inline VdfVectorIterator<T>&
VdfVectorIterator<T>::operator++()
{
    ++_dataIndex;
    ++_logicalOffset;
    // Only iterators not at the end are allowed to be incremented so _mapping
    // must be valid.  When increment moves this iterator to the end, _mapping
    // points past the end of its array.  It cannot be accessed after it has
    // been incremented.
    if (_dataIndex == _mapping->dataEndIndex) {
        // Reset the offset within the block when advancing to a new block.
        _logicalOffset = 0;
        ++_mapping;
    }
    return *this;
}

template <typename T>
inline bool
VdfVectorIterator<T>::AdvanceTo(size_t idx)
{
    while (!IsAtEnd() && _GetIndex() < idx) {
        ++(*this);
    }

    return !IsAtEnd() && _GetIndex() == idx;
}

template <typename T>
VdfVectorIterator<T>::VdfVectorIterator(
    const Vdf_VectorData::Info &info)
{
    if (ARCH_UNLIKELY(info.compressedIndexMapping)) {
        const Vdf_CompressedIndexMapping::_BlockMappings& mappings =
            info.compressedIndexMapping->_blockMappings;
        const size_t numValues = mappings.empty()
            ? 0
            : mappings.back().dataEndIndex;
        _begin = reinterpret_cast<const T*>(info.data);
        _end = reinterpret_cast<const T*>(info.data) + numValues;

        _mapping = mappings.data();
    }
    else if (info.layout != Vdf_VectorData::Info::Layout::Boxed) {
        const size_t numValues = info.size == 0
            ? 0
            : info.last - info.first + 1;
        _begin = reinterpret_cast<const T*>(info.data);
        _end = reinterpret_cast<const T*>(info.data) + numValues;

        _localMapping.logicalStartIndex = info.first;
        _localMapping.dataEndIndex = numValues;
        _mapping = &_localMapping;
    }
    else {
        using BoxedVectorType = Vdf_BoxedContainer<T>;
        BoxedVectorType *boxedVector =
            reinterpret_cast<BoxedVectorType*>(info.data);
        const size_t numValues = boxedVector->size();
        _begin = boxedVector->data();
        _end = boxedVector->data() + numValues;

        _localMapping.logicalStartIndex = 0;
        _localMapping.dataEndIndex = numValues;
        _mapping = &_localMapping;
    }
}

PXR_NAMESPACE_CLOSE_SCOPE

#endif
