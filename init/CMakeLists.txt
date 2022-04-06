cmake_minimum_required(VERSION 3.17)

project(init C)

set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

add_library(init OBJECT main.c)
target_compile_options(init PUBLIC ${GCCFLAGS})
target_include_directories(init PUBLIC "${INCLUDE_DIR}")
