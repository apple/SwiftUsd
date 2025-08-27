# Release Checklist

Checklist for releasing new versions of SwiftUsd

## 1. Decide on a new SwiftUsd version number
1. If creating a new major version, make sure all small source-breaking changes are done


## 2. If OpenUSD was changed
1. [Rebuild OpenUSD](<doc:BuildingLocally>)
1. [Generate a new `openusd-patch.patch`](<doc:CheatSheet#Generating-a-new-patch>)
1. [Compare changes to the patch](<doc:CheatSheet#Comparing-the-differences-between-an-old-patch-and-a-new-patch>)
1. Move the patch to `SwiftUsd/openusd-patch.patch`
1. Update [Changes to OpenUSD](<doc:ChangesToOpenUSD>)
1. Remove `swift-package` and run `./scripts/make-swift-package.zsh openusd-builds/macOS openusd-builds/iOS`


## 3. If ast-answerer was changed
1. Run `ast-answerer/analysis_change.py` and look at the differences in the analysis outputs


## 4. If source files have been added or removed
1. Remove `swift-package` and run `python3 scripts/make-swift-package.zsh`
1. Add to `swiftUsd.h` umbrella header
1. Review changes via `git status` and `git diff`


## 5. Testing
1. Add tests for all added, changed, deprecated API
1. Run `SwiftUsdTests` in Release mode on current compiler
1. Run `SwiftUsdTests` in Debug mode on current compiler
1. Run `SwiftUsdTests` in Release mode on pre-release compiler
1. Run `SwiftUsdTests` in Debug mode on pre-release compiler
1. If major changes have been made, test all sample projects


## 6. Documentation, manual
1. Update versions:
    1. OpenUSD
        1. [Getting Started](<doc:GettingStarted>)
        1. [Building Locally](<doc:BuildingLocally>)
    1. Pixar namespace
        1. [Getting Started, "Using SwiftUsd"](<doc:GettingStarted#Using-SwiftUsd>)
        1. [Getting Started, "Common Issues"](<doc:GettingStarted#Common-issues>)
    1. Xcode, OS
        1. [Getting Started](<doc:GettingStarted>). Include build numbers as well
    1. SwiftUsd
        1. README.md, "Swift Package"
        1. [Getting Started, "Swift Package"](<doc:GettingStarted#Swift-Package>)
        1. make-spm-tests.py in SwiftUsdTests
        1. project.pbxproj in SwiftUsdTests
1. If files have been added or removed, update [Miscellaneous, "Repo structure"](<doc:Miscellaneous#Repo-structure>)
1. Update [Ongoing Work](<doc:OngoingWork>)
1. Update the [Change Log](<doc:ChangeLog>)
1. Review changes via `git status` and `git diff`


## 7. Documentation, pipeline
1. [Build documentation](<doc:CheatSheet#Building-documentation>)
1. [Preview documentation](<doc:CheatSheet#Previewing-documentation>)
    - There should be no warnings when previewing documentation  
1. [Publish documentation](<doc:CheatSheet#Publishing-documentation>)
1. Review changes via `git status` and `git diff`


## 8. Final steps
1. Review changes to `SwiftUsdTests`
1. Review changes to `ast-answerer`
1. Commit changes to `SwiftUsd`, `SwiftUsdTests`, `ast-answerer`
1. Add git tag
1. Push commit and tag to remote
1. Push `SwiftUsdTests`, `ast-answerer` to remote







