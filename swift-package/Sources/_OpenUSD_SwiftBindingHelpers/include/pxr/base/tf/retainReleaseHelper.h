//
//  retainReleaseHelper.h
//
//
//  Created by Maddy Adams on 10/12/23.
//

#ifndef retainReleaseHelper_hpp
#define retainReleaseHelper_hpp

#include "pxr/pxr.h"
#include "pxr/base/tf/refBase.h"
#include "pxr/base/tf/refPtr.h"

PXR_NAMESPACE_OPEN_SCOPE

// This class exposes functions to manually manipulate the reference count of a TfRefBase.
// Never call these functions directly; they are provided for the purposes of importing TfRefBase
// with reference counting semantics into a language with automatic reference counting mechanisms.

// TfRefPtr<TfRefBase> isn't supported, so we can't use the static member functions.
// Instead, just use the no-unique-change-counter body
class Tf_RetainReleaseHelper {
public:
    // Increments the reference count of the argument by 1.
    template <class T>
    inline static void retain(T* obj) {
        if constexpr (std::is_same_v<pxr::TfRefBase, T>) {
            pxr::Tf_RefPtr_Counter::AddRef(obj);
        } else {
            TfRefPtr<T>::_AddRefStatic(obj);
        }
    }

    // Decrements the reference count of the argument by 1, deleting the argument
    // if the reference count reaches 0.
    template <class T>
    inline static void release(T* obj) {
        if constexpr (std::is_same_v<pxr::TfRefBase, T>) {
            if (pxr::Tf_RefPtr_Counter::RemoveRef(obj)) {
                pxr::Tf_RefPtrTracker_LastRef(nullptr,
                                              reinterpret_cast<T*>(const_cast<TfRefBase*>(obj)),
                                              nullptr);
                delete obj;
            }
        } else{
            TfRefPtr<T>::_RemoveRefStatic(obj);
        }
    }
};

PXR_NAMESPACE_CLOSE_SCOPE

#endif /* retainReleaseHelper_h */
