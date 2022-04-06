cmake_minimum_required(VERSION 3.17)

set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

project(lib C)

set(LIB_NAME lib)
add_library(${LIB_NAME} STATIC
        ctype.c _exit.c open.c
        close.c errno.c write.c
        dup.c setsid.c execve.c
        wait.c string.c malloc.c)
target_compile_options(${LIB_NAME} PUBLIC ${GCCFLAGS})
target_include_directories(${LIB_NAME} PUBLIC "${INCLUDE_DIR}")
