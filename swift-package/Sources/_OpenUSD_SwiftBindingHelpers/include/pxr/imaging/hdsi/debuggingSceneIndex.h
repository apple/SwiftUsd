//
// Copyright 2025 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_IMAGING_HDSI_DEBUGGING_SCENE_INDEX_H
#define PXR_IMAGING_HDSI_DEBUGGING_SCENE_INDEX_H

#include "pxr/imaging/hd/filteringSceneIndex.h"
#include "pxr/imaging/hdsi/api.h"
#include "pxr/pxr.h"

#include <optional>
#include <map>
#include <mutex>

PXR_NAMESPACE_OPEN_SCOPE

TF_DECLARE_WEAK_AND_REF_PTRS(HdsiDebuggingSceneIndex);

namespace HdsiDebuggingSceneIndex_Impl
{

// Per prim-info.
//
// We always store a prim info for all ancestors as well.
// In particular, we always store a prim info for the absolute root /.
//
struct _PrimInfo
{
    // Does a prim exist?
    //
    // Note that the HdSceneIndexBase does not specify whether a prim "exists".
    //
    // There are two notions of existence:
    // - The strong form is that GetPrim("/foo") returns a non-empty prim type
    //   or non-null data source handle.
    // - The weak form (existence in namespace) is that a prim exists at a path
    //   if (without a subsequent PrimRemovedEntry):
    //   * We have received a PrimAddedEntry for the path or a descendant path
    //   * GetPrim for path or a descendant path returned a non-empty prim type
    //     or non-null data source
    //   * GetChildPrimPaths for path or a descendant path was non-empty
    //   * path is in GetChildPrimPaths(parentPath)
    //
    // Here we assume the weaker form.
    //
    // If a prim exists (in namespace), there will be a prim-info for all its
    // ancestors which are also assumed to exist.
    //
    // Note that the debugging scene index (lazily) only queries GetPrim or
    // GetChildPrimPaths itself when the client calls that method.
    //
    // If we receive a PrimRemovedEntry, we set _PrimInfo::exists = false for
    // the corresponding prim info. Such a _PrimInfo has no descendants.
    //
    // Note that the implementation could be changed to just use a bool if
    // we were to use _PrimInfo::insert instead of _PrimInfo[].
    //
    std::optional<bool> existsInNamespace;

    // Do we know all children of this prim?
    //
    // True if GetChildPrimPaths(path) was called or we received
    // PrimRemovedEntry(path).
    //
    bool allChildrenKnown = false;

    // primType if known.
    std::optional<TfToken> primType;

    // Does this prim have a non-null ptr data source?
    //
    // Future work might store more information about the data source and wrap
    // it so that we can track which values were returned to a client.
    //
    std::optional<bool> hasDataSource;
};
using _PrimInfoSharedPtr = std::shared_ptr<_PrimInfo>;
using _PrimMap = std::map<SdfPath, _PrimInfo>;

}

/// \class HdsiDebuggingSceneIndex
///
/// A filtering scene index that checks for certain inconsistencies (without
/// transforming the scene) in its input scene.
/// For example, it will report if the input scene's GetPrim(/foo) returns a
/// prim type different from a previous call to GetPrim(/foo) even though the
/// input scene sent no related prims added or removed notice.
///
/// The easiest way to invoke this scene index is by setting the env var
/// HDSI_DEBUGGING_SCENE_INDEX_INSERTION_PHASE. Also see
/// HdsiDebuggingSceneIndexPlugin.
///
class HdsiDebuggingSceneIndex : public HdSingleInputFilteringSceneIndexBase
{
public:
    HDSI_API
    static HdsiDebuggingSceneIndexRefPtr
    New(HdSceneIndexBaseRefPtr const &inputSceneIndex,
        HdContainerDataSourceHandle const &inputArgs);

    HDSI_API
    ~HdsiDebuggingSceneIndex() override;

    HDSI_API
    HdSceneIndexPrim GetPrim(const SdfPath &primPath) const override;

    HDSI_API
    SdfPathVector GetChildPrimPaths(const SdfPath &primPath) const override;

protected:
    HDSI_API
    void _PrimsAdded(
        const HdSceneIndexBase &sender,
        const HdSceneIndexObserver::AddedPrimEntries &entries) override;

    HDSI_API
    void _PrimsRemoved(
        const HdSceneIndexBase &sender,
        const HdSceneIndexObserver::RemovedPrimEntries &entries) override;

    HDSI_API
    void _PrimsDirtied(
        const HdSceneIndexBase &sender,
        const HdSceneIndexObserver::DirtiedPrimEntries &entries) override;

    HDSI_API
    void _PrimsRenamed(
        const HdSceneIndexBase &sender,
        const HdSceneIndexObserver::RenamedPrimEntries &entries) override;

private:
    HdsiDebuggingSceneIndex(HdSceneIndexBaseRefPtr const &inputSceneIndex,
                            HdContainerDataSourceHandle const &inputArgs);

    mutable std::mutex _primsMutex;
    mutable HdsiDebuggingSceneIndex_Impl::_PrimMap _prims;
};

PXR_NAMESPACE_CLOSE_SCOPE

#endif // PXR_IMAGING_HD_DEBUGGING_SCENE_INDEX_H
