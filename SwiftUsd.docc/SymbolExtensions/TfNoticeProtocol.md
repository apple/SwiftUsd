# ``/OpenUSD/C++/SwiftUsd/TfNoticeProtocol``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}

Protocol representing `pxr::TfNotice` subclasses.

If you create custom [`pxr::TfNotice`](doc:/OpenUSD/C++/pxr/TfNotice) subclasses in C++, you can enable SwiftUsd's [`pxr.TfNotice.Register`](doc:/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-olq9) for them by conforming to this protocol and following the patterns in `SwiftUsd/source/generated/GeneratedTfNoticeProtocol.swift` by rote.
