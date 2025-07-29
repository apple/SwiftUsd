# ``/OpenUSD/C++/pxr/TfNotice/Register(_:_:)-olq9``

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}

Register a listener as being interested in a TfNotice, regardless of sender. 

Registration of interest in a notice class `N` automatically registers interest in all classes derived from `N`. When a notice of appropriate type is received, the `callback` is called with the notice.

To reverse the registration, call ``OpenUSD/Revoke-31sr0`` on the ``/OpenUSD/SwiftKey`` object returned by this call.

This form of registration listens for a notice globally. Prefer listening to a notice from a particular sender whenever possible (see overloads).

Additionally, all forms of registration can also support dynamically downcasting notice types in the callback (see overloads).