# ``/OpenUSD/C++/pxr/TfNotice/NoticeCaster``

## Overview

Use this type's ``callAsFunction(_:)`` or ``cast(to:)`` functions to conditionally downcast notices in a [`pxr.TfNotice.Register`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-99j13) callback. 

```swift
func registerWithDowncasting() {
    pxr.TfNotice.Register(pxr.UsdNotice.StageNotice.self) { notice, caster in
        if let layerMutingChanged = caster(pxr.UsdNotice.LayerMutingChanged.self) {
            print("Muted: \(layerMutingChanged.GetMutedLayers())")
            print("Unmuted: \(layerMutingChanged.GetUnmutedLayers())")
        } else if let stageEditTargetChanged = caster(pxr.UsdNotice.StageEditTargetChanged.self) {
            print("Stage edit target changed: \(stageEditTargetChanged.GetStage())")
        }
    }
}
```