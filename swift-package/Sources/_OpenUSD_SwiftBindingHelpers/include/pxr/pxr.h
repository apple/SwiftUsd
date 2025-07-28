//
// Copyright 2016 Pixar
//
// Licensed under the terms set forth in the LICENSE.txt file available at
// https://openusd.org/license.
//
#ifndef PXR_H
#define PXR_H

/// \file pxr/pxr.h

#define PXR_MAJOR_VERSION 0
#define PXR_MINOR_VERSION 25
#define PXR_PATCH_VERSION 5

#define PXR_VERSION 2505

#define PXR_USE_NAMESPACES 1

#if PXR_USE_NAMESPACES

#define PXR_NS pxr
#define PXR_INTERNAL_NS pxrInternal_v0_25_5__pxrReserved__
#define PXR_NS_GLOBAL ::PXR_NS

namespace PXR_INTERNAL_NS { }

// The root level namespace for all source in the USD distribution.
namespace PXR_NS {
    using namespace PXR_INTERNAL_NS;
}

#define PXR_NAMESPACE_OPEN_SCOPE   namespace PXR_INTERNAL_NS {
#define PXR_NAMESPACE_CLOSE_SCOPE  }  
#define PXR_NAMESPACE_USING_DIRECTIVE using namespace PXR_NS;

#else

#define PXR_NS 
#define PXR_NS_GLOBAL 
#define PXR_NAMESPACE_OPEN_SCOPE   
#define PXR_NAMESPACE_CLOSE_SCOPE 
#define PXR_NAMESPACE_USING_DIRECTIVE

#endif // PXR_USE_NAMESPACES

#if 0
#define PXR_PYTHON_SUPPORT_ENABLED
#endif

#if 1
#define PXR_PREFER_SAFETY_OVER_SPEED
#endif

#define PXR_USE_INTERNAL_BOOST_PYTHON

#endif //PXR_H
