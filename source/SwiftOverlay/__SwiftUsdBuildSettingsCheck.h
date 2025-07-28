//
//  __SwiftUsdBuildSettingsCheck.h
//
//  Created by Maddy Adams on 10/31/2024.
//

#ifndef SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H
#define SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H

// Note: This file checks for the correct build settings when using SwiftUsd.
// Don't include this file in a C++ source file.

#if __cplusplus < 201700 || __cplusplus > 201799
#error "Invalid C++ language version, C++17 or GNU++17 is required for SwiftUsd. Check `CLANG_CXX_LANGUAGE_STANDARD` in Xcode build settings or `-std=` on the command line"
#endif // __cplusplus < 201700 || __cplusplus > 201799


#ifndef __swift__
#error "Invalid Swift-Cxx interop mode, enabled interop is required for SwiftUsd. Check `SWIFT_OBJC_INTEROP_MODE` in Xcode build settings or `-cxx-interoperability-mode=` on the command line"
#endif // __swift__

#endif /* SWIFTUSD_SWIFTOVERLAY___SWIFTUSDBUILDSETTINGSCHECK_H */
