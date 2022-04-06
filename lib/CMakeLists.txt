cmake_minimum_required(VERSION 3.17)

project(lib C)

set(LIB_NAME lib)
add_library(lib STATIC
        ctype.c _exit.c open.c
        close.c errno.c write.c
        dup.c setsid.c execve.c
        wait.c string.c malloc.c)
target_compile_options(lib PUBLIC ${GCCFLAGS})
target_include_directories(lib PUBLIC "${INCLUDE_DIR}")
