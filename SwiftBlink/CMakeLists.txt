cmake_minimum_required(VERSION 3.22)

add_library(SwiftBlink STATIC)

file(GLOB_RECURSE SWIFT_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.swift
)

target_sources(SwiftBlink PRIVATE
    ${SWIFT_SOURCES}
)

target_link_libraries(SwiftBlink PRIVATE
    stm32cubemx
)

target_compile_options(SwiftBlink PRIVATE
    -target armv7em-none-none-eabi
    "SHELL:-Xcc -mthumb"
    "SHELL:-Xcc -mcpu=cortex-m4"
    "SHELL:-Xcc -mfloat-abi=hard"
    "SHELL:-Xcc -mfpu=fpv4-sp-d16"
    "SHELL:-Xcc -ffreestanding"
    "SHELL:-Xcc -fshort-enums"
    "SHELL:-Xcc -DSTM32F411xE"
    "SHELL:-Xcc -DUSE_HAL_DRIVER"
    -Osize
    -wmo
    -enable-experimental-feature Embedded
    -Xfrontend -function-sections
    -import-bridging-header ${CMAKE_CURRENT_SOURCE_DIR}/../Core/Inc/main.h
)
