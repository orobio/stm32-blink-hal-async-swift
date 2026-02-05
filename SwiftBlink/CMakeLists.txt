cmake_minimum_required(VERSION 3.22)

add_library(SwiftBlinkImpl STATIC)

file(GLOB_RECURSE SWIFT_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/Support/*.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/*.swift
)

target_sources(SwiftBlinkImpl PRIVATE
    ${SWIFT_SOURCES}
)

target_include_directories(SwiftBlinkImpl PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../swift-runtime/embedded
)

target_link_libraries(SwiftBlinkImpl PRIVATE
    stm32cubemx
    m
)

execute_process(
    COMMAND ${CMAKE_C_COMPILER} --print-sysroot
    OUTPUT_VARIABLE C_SYSROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

target_compile_options(SwiftBlinkImpl PRIVATE
    -target armv7em-none-none-eabi
    "SHELL:-Xcc -mthumb"
    "SHELL:-Xcc -mcpu=cortex-m4"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -mfpu=fpv4-sp-d16"
    "SHELL:-Xcc -ffreestanding"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -DSTM32F411xE"
    "SHELL:-Xcc -DUSE_HAL_DRIVER"
    "SHELL:-Xcc -isystem${C_SYSROOT}/include"
    -Osize
    -wmo
    -enable-experimental-feature Embedded
    -Xfrontend -function-sections
    -import-bridging-header ${CMAKE_CURRENT_SOURCE_DIR}/BridgingHeader.h
)

# Use interface library to fix circular dependencies between SwiftBlinkImpl and the runtime libraries.
# Symbols like swift_retain, swift_slowAlloc, etc. are created from the Swift runtime modules and included in SwiftBlinkImpl.
add_library(SwiftBlink INTERFACE)

target_link_libraries(SwiftBlink INTERFACE
    -Wl,--start-group
    SwiftBlinkImpl
    ${CMAKE_CURRENT_SOURCE_DIR}/../swift-runtime/embedded/armv7em-none-none-eabi/libswift_Concurrency.a
    -Wl,--end-group
    stdc++
)
