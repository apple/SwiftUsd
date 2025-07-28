//
//  Usd_PrimFlags.h
//
//
//  Created by Maddy Adams on 6/7/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H
#define SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H

#include "pxr/usd/usd/primFlags.h"

namespace Overlay {
  extern const pxr::Usd_PrimFlags Usd_PrimActiveFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimLoadedFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimModelFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimGroupFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimComponentFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimAbstractFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimDefinedFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimHasDefiningSpecifierFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimInstanceFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimHasPayloadFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimClipsFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimDeadFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimPrototypeFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimInstanceProxyFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimPseudoRootFlag;
  extern const pxr::Usd_PrimFlags Usd_PrimNumFlags;
}
namespace Overlay {
  extern const pxr::Usd_PrimFlagsPredicate UsdPrimDefaultPredicate;
}


#endif /* SWIFTUSD_SWIFTOVERLAY_USD_PRIMFLAGS_H */
