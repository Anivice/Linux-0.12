project(chr_drv C ASM)

set(LIB_NAME chr_drv)

set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

add_library(${LIB_NAME} STATIC rs_io.s console.c serial.c tty_io.c tty_ioctl.c kb.S)
target_compile_options(${LIB_NAME} PUBLIC ${GCCFLAGS})
target_include_directories(${LIB_NAME} PUBLIC "${INCLUDE_DIR}")


