# ``/OpenUSD/C++/pxr/TfNotice/Register(_:_:_:)-(_,_,(Notice,Sender,pxr.TfNotice.NoticeCaster)->())``

Register a listener as being interested in a TfNotice from a particular sender.

Registration of interest in a notice class `N` automatically registers interest in all classes derived from `N`. When a notice of appropriate type is received, the `callback` is called with the notice. To dynamically downcast notice types in the callback, use the ``/OpenUSD/C++/pxr/TfNotice/NoticeCaster`` parameter.

To reverse the registration, call ``OpenUSD/Revoke-31sr0`` on the ``/OpenUSD/SwiftKey`` object returned by this call.

This form of registration listens for notices from a particular sender, receiving the sender in the callback. The sender being registered for must be derived from `pxr::TfWeakBase`. 