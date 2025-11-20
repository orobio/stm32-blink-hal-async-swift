# Swift runtime

This directory provides a pre-built Swift 6.2.2 runtime for armv7em-none-none-eabi, compiled with newlib and libstdc++.

## Build configuration

The runtime was built using [the Ubuntu 24.04 Swift CI container](https://github.com/swiftlang/swift-docker/blob/316ca5e929038cd2af1c13d8acbbbeb35415e181/swift-ci/main/ubuntu/24.04/Dockerfile). Additionally, the libnewlib-arm-none-eabi package was installed (which brings in a number of related packages, including libstdc++-arm-none-eabi-newlib).

### Patches

The build is based on the swift-6.2.2-RELEASE tag, with a number of patches applied to the Swift repository in order to enable concurrency support and be able to build with newlib/libstdc++. The patches can be found in the [swift-patches](./swift-patches/)  directory.

## Runtime support

[swift-runtime-support.c](./swift-runtime-support.c) provides a number of additional system functions that are required by the runtime.
