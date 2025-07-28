# Working with TfNotice

Learn how to use the TfNotice notification subsystem in Swift

## Overview

OpenUSD includes a notification subsystem based on `pxr::TfNotice` and `pxr::TfNotice::Register` for use in C++. SwiftUsd exposes this system to Swift with minor modifications.

Like in C++, TfNotice registration in Swift comes in three main forms:
- [`pxr.TfNotice.Register(_:_:)`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-olq9) to register for a particular notice type, regardless of sender
- [`pxr.TfNotice.Register(_:_:_:)`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:_:)-u8ws) to register for a particular notice type from a specific sender, without retrieving the sender in the notification callback
- [`pxr.TfNotice.Register(_:_:_:)`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:_:)-(_,_,(Notice,Sender)->())) to register for a particular notice type from a specific sender while retrieving the sender in the notification callback

Example usage:
```swift
class StageWatcher {
    var stage: pxr.UsdStage
    var key: pxr.TfNotice.SwiftKey

    init(stage: pxr.UsdStage) {
        self.stage = stage

        key = pxr.TfNotice.Register(stage, pxr.UsdNotice.ObjectsChanged.self) { notice in
            print("Resynced: \(notice.GetResyncedPaths())")
            print("Changed info only: \(notice.GetChangedInfoOnlyPaths())")
        }
    }
    deinit {
        pxr.TfNotice.Revoke(key)
    }
}
```

## Downcasting and inheritance

When registering for a notice type, your notification callback may be called if notices that derive from the notice type you registered for are sent. To support conditional casting of `TfNotice` values in the notification callback, SwiftUsd provides ``/OpenUSD/C++/pxr/TfNotice/NoticeCaster`` and three auxillary forms of [`pxr.TfNotice.Register()`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-olq9) that provide the [`NoticeCaster`](doc:/OpenUSD/C++/pxr/TfNotice/NoticeCaster) as a parameter to the notification callback:

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

## Cancellation

To cancel a notification callback, pass the return value from [`pxr.TfNotice.Register`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-olq9) to [`pxr.TfNotice.Revoke`](doc:/OpenUSD/Revoke-31sr0):

```swift
func registerWithRevoking(stage: pxr.UsdStage) {
    let key = pxr.TfNotice.Register(stage, pxr.UsdNotice.StageContentsChanged.self) { _ in
        print("Stage contents changed")
    }

    stage.SetStartTimeCode(5) // prints "Stage contents changed"
    stage.SetEndTimeCode(7) // prints "Stage contents changed"
    pxr.TfNotice.Revoke(key)
    stage.SetTimeCodesPerSecond(60) // no print
}
```

## Swift-Cxx interoperability

The C++ and Swift versions of [`pxr::TfNotice`](doc:/OpenUSD/C++/pxr/TfNotice) can interoperate with each other. The C++ return type [`pxr::TfNotice::Key`](doc:/OpenUSD/C++/pxr/TfNotice/Key) can be converted into the Swift return type [`pxr::TfNotice::SwiftKey`](doc:/OpenUSD/SwiftKey), and both return types can be revoked from either language.

```c++
pxr::TfNotice::Key registerForChanges(pxr::UsdStageWeakPtr);
```

```swift
class KeyHolder {
    var keys = pxr.TfNotice.SwiftKeys()

    init() {}

    func callCppRegisterForChanges(stage: pxr.UsdStageWeakPtr) {
        let cppKey = registerForChanges(stage)
        let swiftKey = pxr.TfNotice.SwiftKey(cppKey)
        keys.push_back(swiftKey)
    }

    func revokeAll() {
        pxr.TfNotice.Revoke(&keys)
    }
}
```