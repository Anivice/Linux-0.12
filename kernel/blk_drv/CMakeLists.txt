cmake_minimum_required(VERSION 3.17)

project(blk_drv C)

set(LIB_NAME blk_drv)

set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

add_library(${LIB_NAME} STATIC floppy.c hd.c ll_rw_blk.c ramdisk.c)
target_compile_options(${LIB_NAME} PUBLIC ${GCCFLAGS})
target_include_directories(${LIB_NAME} PUBLIC "${INCLUDE_DIR}")
