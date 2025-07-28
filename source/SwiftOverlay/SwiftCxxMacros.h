//
//  SwiftCxxMacros.h
//  swiftUsd
//
//  Created by Maddy Adams on 11/20/24.
//

#ifndef SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H
#define SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H

#include <swift/bridging>

#define SWIFT_UNAVAILABLE_MESSAGE(msg) __attribute__((availability(swift, unavailable, message=msg)))
#define SWIFT_UNAVAILABLE __attribute__((availability(swift, unavailable)))



// Swift 6.1 compiler provides SWIFT_RETURNS_RETAINED and SWIFT_RETURNS_UNRETAINED,
// but we want to have clear annotations for Swift 6.0, even if they don't do anything
#ifndef SWIFT_RETURNS_RETAINED
#define SWIFT_RETURNS_RETAINED __attribute__((swift_attr("returns_retained"))) __attribute__((cf_returns_retained))
#endif

#ifndef SWIFT_RETURNS_UNRETAINED
#define SWIFT_RETURNS_UNRETAINED __attribute__((swift_attr("returns_unretained"))) __attribute__((cf_returns_not_retained))
#endif



#endif /* SWIFTUSD_SWIFTOVERLAY_SWIFTCXXMACROS_H */
