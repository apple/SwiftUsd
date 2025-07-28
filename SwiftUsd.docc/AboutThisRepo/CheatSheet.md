# Cheat sheet

Tips for advanced users modifying this repo

## Overview
This page contains some useful Terminal commands for working on this repo. If you're just trying to use OpenUSD in Swift, the information here won't be helpful. Most users should ignore this page. 

### Documentation
`swift package generate-documentation` runs into issues with SwiftUsd. (See [here](https://github.com/swiftlang/swift-docc-plugin/issues/80).) Instead, `SwiftUsd` provides its own workflow for building, previewing, and publishing documentation. 

#### Building documentation
To build the DocC symbol graphs, run:
```zsh
cd ~/SwiftUsd
swift run --package-path scripts/docc build-documentation
```
This will take several minutes, and create a `Package.resolved` file, a `.build` directory, and a `.symbol-graphs` directory. 
> Note, even if `swift package generate-documentation` starts working, using `scripts/docc build-documentation` is still the recommended approach, because it also manipulates the symbol graphs to look nicer for Swift-Cxx interop (e.g. hiding the long Pixar internal namespace, hiding C++ DocC workarounds) in addition to symlinking generated markdown files into the documentation catalog. 

#### Previewing documentation
- Prerequisite: You already ran `build-documentation`.  
To preview the DocC documentation locally, run:
```zsh
cd ~/SwiftUsd
swift run --package-path scripts/docc preview-documentation
```
This script will automatically open a window in your web browser viewing the locally hosted documentation. You can modify the markdown files in the documentation catalog and the preview will automatically update. (You may need to refresh the page, and the updating may take a few seconds.)

#### Publishing documentation
- Prerequisite: You already ran `build-documentation`.  
- Prerequisite: You already ran `preview-documentation` and there were no documentation warnings or errors.  
To update the published documentation, run:
```zsh
cd ~/SwiftUsd
swift run --package-path scripts/docc update-documentation
```
This script will update the `SwiftUsd.doccarchive` that is viewable locally in Xcode, as well as the `docs` directory that powers the online documentation hosted at [https://apple.github.io/SwiftUsd/documentation/openusd/](https://apple.github.io/SwiftUsd/documentation/openusd/). 


### Patches
- Prerequisite: `~/OpenUSD` is an unmodified version of OpenUSD. 
- Prerequisite: You've already cloned OpenUSD to `SwiftUsd/openusd-source`. 

#### Generating a new patch
```zsh
cd ~/SwiftUsd/openusd-source
diff -Nura \
    --exclude .git --exclude '*.orig' \
    --exclude .DS_Store --exclude '*.pyc' \
    ~/OpenUSD . > ~/Desktop/wip.patch
```

#### Viewing the list of files changed from OpenUSD
```zsh
cd ~/SwiftUsd/openusd-source
diff -Nqra \
    --exclude .git --exclude '*.orig' \
    --exclude .DS_Store --exclude '*.pyc' \
    ~/OpenUSD .
```

#### Comparing the differences between an old patch and a new patch
- Prerequisite: You generated a new patch at `~/Desktop/wip.patch`
```zsh
diff -ua \
    -I '^(diff |\+\+\+ |--- |@@ |\ | )' \
    ~/SwiftUsd/openusd-patch.patch ~/Desktop/wip.patch
```

### Reviewing commit changes
```zsh
git status ":(exclude)docs/*" ":(exclude)SwiftUsd.doccarchive/*" ":(exclude)swift-package/XCFrameworks/*.xcframework/Info.plist"
git diff ":(exclude)docs/*" ":(exclude)SwiftUsd.doccarchive/*" ":(exclude)swift-package/XCFrameworks/*.xcframework/Info.plist"
```

### Grep
Grepping for text in the entire package will likely pull up useless matches from various hidden directories and build artifacts. To get more relevant matches, use something like this: 
```zsh
grep SEARCHPATTERN -r scripts source SwiftUsd.docc Package.swift --exclude-dir={.docc-build,.build}
```
