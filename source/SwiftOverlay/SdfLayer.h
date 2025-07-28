//
//  SdfLayer.h
//
//  Created by Maddy Adams on 3/28/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_SDFLAYER_H
#define SWIFTUSD_SWIFTOVERLAY_SDFLAYER_H

#include <string>
#include "pxr/pxr.h"
#include "pxr/usd/sdf/layer.h"

namespace Overlay {
    namespace SdfLayer {
        pxr::SdfLayer::TraversalFunction TraversalFunction(void (^f)(const pxr::SdfPath&));
    }
}

#endif /* SWIFTUSD_SWIFTOVERLAY_SDFLAYER_H */
