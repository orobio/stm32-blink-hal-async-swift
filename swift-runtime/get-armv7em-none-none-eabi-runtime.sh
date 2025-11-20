#!/bin/bash
# Gets armv7em-none-none-eabi related files from original Swift embedded directory

SWIFT_EMBEDDED_PATH=$1
if [[ "${SWIFT_EMBEDDED_PATH}" = "" ]]; then
    echo "usage: $0 <path to swift embedded libraries>  # Example path: /ust/lib/swift/embedded"
    exit 1
fi

set -e nounset
set -e errexit

if [[ -e embedded ]]; then
    echo "error: 'embedded' directory already exists. Please delete it first."
    exit 1
fi
mkdir embedded

# Modules
modules=`cd ${SWIFT_EMBEDDED_PATH} && find -maxdepth 1 -type d -name "*.swiftmodule"`
for module in ${modules}; do
    mkdir embedded/${module}
    cp ${SWIFT_EMBEDDED_PATH}/${module}/armv7em-none-none-eabi.swiftmodule embedded/${module}
done

# CXX shims
cp ${SWIFT_EMBEDDED_PATH}/libcxxshim.h embedded/
cp ${SWIFT_EMBEDDED_PATH}/libcxxshim.modulemap embedded/
cp ${SWIFT_EMBEDDED_PATH}/libcxxstdlibshim.h embedded/

# Libraries
cp ${SWIFT_EMBEDDED_PATH}/armv7em-none-none-eabi embedded/armv7em-none-none-eabi -r

