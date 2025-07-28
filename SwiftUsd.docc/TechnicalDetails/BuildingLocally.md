# Building locally

Learn how to use SwiftUsd with local/existing OpenUSD binaries

## Overview

SwiftUsd comes with pre-built OpenUSD binaries that make it easy to start using SwiftUsd without additional setup. To do so, follow the instructions in <doc:GettingStarted> to add SwiftUsd as a remote package dependency to an Xcode project or Swift Package. However, if you want to use SwiftUsd with different Usd feature flags or on other platforms/architectures, you can build OpenUSD to your specifications, and then create a Swift Package that lets you use your OpenUSD build in Swift.

1. Clone SwiftUsd
```zsh
git clone git@github.com:apple/SwiftUsd.git ~/SwiftUsd
```

2. Clone OpenUSD v25.05.01
```zsh
git clone https://github.com/PixarAnimationStudios/OpenUSD.git ~/SwiftUsd/openusd-source
cd ~/SwiftUsd/openusd-source
git checkout v25.05.01
```

3. Apply `openusd-source.patch` to it  
```zsh
cd ~/SwiftUsd/openusd-source
patch -p1 -i ~/SwiftUsd/openusd-patch.patch
```

4. Build OpenUSD for one more more platforms with feature flags of your choosing. These are the feature flags that SwiftUsd is built with by default:
```zsh
cd ~/SwiftUsd/openusd-source
python3 build_scripts/build_usd.py \
    --embree \
    --openimageio \
    --alembic \
    --no-python \
    --ignore-homebrew \
    --build-target native \
    ~/SwiftUsd/openusd-builds/macOS

cd ~/SwiftUsd/openusd-source
python3 build_scripts/build_usd.py \
    --alembic \
    --no-python \
    --ignore-homebrew \
    --build-target iOS \
    ~/SwiftUsd/openusd-builds/iOS
```

> Note: Custom feature flags are experimental, and may have some restrictions. For example, building with Python will not work on Apple platforms, building with additional plugins may not work for app-bundlable packages, and packaging multiple Usd builds with incompatible feature flags may not work. 

5. Run `scripts/make-swift-package.zsh`. Use the `--generated-package-dir` flag to create the custom SwiftUsd package at a specific location (defaults to the SwiftUsd repo cloned from git). Note: if making the swift package in place with the following command, remove `swift-package` before running `make-swift-package`. 
```zsh
cd ~/SwiftUsd
./scripts/make-swift-package.zsh openusd-builds/iOS openusd-builds/macOS
```
