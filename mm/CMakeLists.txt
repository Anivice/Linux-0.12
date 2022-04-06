cmake_minimum_required(VERSION 3.17)

project(kernel C ASM)

add_library(mm STATIC memory.c page.s)
target_include_directories(mm PUBLIC "${INCLUDE_DIR}")
target_compile_options(mm PUBLIC ${GCCFLAGS})
