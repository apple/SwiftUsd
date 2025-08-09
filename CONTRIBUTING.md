## Welcome to the SwiftUsd community!

Contributions to SwiftUsd are welcomed and encouraged! 

## Contributing to SwiftUsd

### How You Can Help
We would love contributions in the form of:
* Bug fixes
* Performance improvements
* Documentation
* Small projects/sample code

### Setting Up Your Environment
SwiftUsd requires using Swift 6.1 (Xcode 16.3) or newer.

If you want to use the pre-built OpenUSD binaries for macOS and iOS included as part of SwiftUsd, follow the instructions from the [README](https://github.com/apple/swiftusd) or [Getting Started](https://apple.github.io/SwiftUsd/documentation/swiftusd/gettingstarted).

If you want to use your own locally built OpenUSD binaries, follow the instructions from [Building locally](https://apple.github.io/SwiftUsd/documentation/swiftusd/buildinglocally). 

If you want to run the test suite, clone [SwiftUsd-Tests](https://github.com/apple/swiftusd-tests), then open the Xcode project and run the unit tests through Xcode. Alternatively, after cloning SwiftUsd-Tests, run [`python3 make-spm-tests.py`](https://github.com/apple/SwiftUsd-Tests/blob/main/make-spm-tests.py). This will create a Swift Package named `SPM-Tests` that you can test via Xcode or the command line. 

#### Issues
When filing an issue, please include the following:
* **A concise description of the problem.** If the issue is a crash, include a stack trace. Otherwise, describe the behavior you were expecting to see, along with the behavior you actually observed.
* **A reproducible test case.** Double-check that your test case reproduces the issue. A relatively small sample (roughly within 50 lines of code) is best pasted directly into the description; a larger one may be uploaded as an attachment. Consider reducing the sample to the smallest amount of code possible—a smaller test case is easier to reason about and more appealing to сontributors.
* **A description of the environment that reproduces the problem.** Include information about the Swift compiler's version (`swift --version`), your platform (e.g. macOS version, Linux distro and version), the deployment target (e.g. macOS version, iOS version, Linux version), and what SwiftUsd version (tag) you're using. 

#### Proposing Features
To propose a new feature, please file a new issue. Title it `[Feature Request]: [Brief description of feature]`. For example, `[Feature Request]: Add support for Foo`. Describe the feature in more detail in the body of the issue. 

### Submitting Issues and Pull Requests 

#### PR Style Guide or Format
Please follow the Swift.org guidelines for [incremental development](https://www.swift.org/contributing/#incremental-development) and [writing commit messages](https://www.swift.org/contributing/#commit-messages). Additionally, please keep these guidelines in mind:
* **Don't include changes to `SwiftUsd/Package.swift` or `SwiftUsd/swift-package` in your commits.** These files are programmatically updated by the codeowners by running `SwiftUsd/scripts/make-swift-package` before releasing a new SwiftUsd version. If you're adding or removing source files, you can run `make-swift-package` locally, just don't include the changes to `SwiftUsd/Package.swift` or `SwiftUsd/swift-package` in your commit. 
* **Don't include changes to `SwiftUsd/SwiftUsd.doccarchive` or `SwiftUsd/docs` in your commits.** These files are programmatically updated by the codeowners by running `SwiftUsd/scripts/docc/update-documentation` before releasing a new SwiftUsd version.
* Include changes to `SwiftUsd/openusd-patch.patch` if your pull request requires modifying OpenUSD and recompiling it. (Most commits won't require this.)
* Include changes to `SwiftUsd/SwiftUsd.docc` if your pull request requires updating documentation. For example, if you add a new substantial feature, create a new markdown file that explains how to use it. If you modify `SwiftUsd/SwiftUsd.docc`, please preview the documentation locally and make sure there aren't any warnings. Follow `Building documentation` and `Previewing documentation` from the [Cheat sheet](https://apple.github.io/SwiftUsd/documentation/swiftusd/cheatsheet), but don't do `Publishing documentation` as this would update `SwiftUsd/SwiftUsd.doccarchive` and `SwiftUsd/docs`. 
* Do write tests for functionality impacted by your PR. Open a PR on SwiftUsd-Tests that briefly describes the new tests being added. When you open your PR on SwiftUsd, please include the link to your SwiftUsd-Tests PR.
* Only include changes to `SwiftUsd/source/generated` if your SwiftUsd PR relies on changes to SwiftUsd-ast-answerer. Please copy the result of `SwiftUsd-ast-answerer/build/AstAnswererOutputs/codeGen` directly into `SwiftUsd/source/generated` without further modifications. Open a PR on SwiftUsd-ast-answerer that describes the changes. When you open your PR on SwiftUsd, please include the link to your SwiftUsd-ast-answerer PR. 

If your changes are small, you can include changes to code and documentation in a single (squashed) commit. Otherwise, please squash your commits so that the first commit is just changes to code, and the second is just changes to documentation. (You can use `git rebase -i` for this.)


#### Build
Clone SwiftUsd, then add it as a local Swift Package dependency to Xcode projects or Swift Packages. If the Xcode project or Swift Package already had a remote Swift Package dependency on SwiftUsd, remove the remote dependency before adding the local dependency. 

#### Test
You can run the unit tests as either an Xcode project or a Swift Package. In both cases, start by cloning SwiftUsd-Tests.
To test as an Xcode project:
* Open SwiftUsdTests.xcodeproj
* Remove the remote dependency on SwiftUsd
* Add a local dependency on your local, modified SwiftUsd

To test as a Swift Package:
* Run `python3 make-spm-tests.py` while inside `SwiftUsd-Tests`
* Either open `SwiftUsd-Tests/SPM-Tests/Package.swift` in Xcode and run the tests, or run `swift test` while inside `SwiftUsd-Tests/SPM-Tests`

Whichever method you use for testing, **please run the unit tests in Debug and Release mode.** Testing in both Debug and Release mode is important, as some Swift-Cxx interop bugs only occur in Debug or Release and not both. 


## Code of Conduct
To clarify of what is expected of our members, SwiftUsd has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities and articulates our values well. 
For more detail, please read the [Code of Conduct](https://github.com/apple/.github/blob/main/CODE_OF_CONDUCT.md).
