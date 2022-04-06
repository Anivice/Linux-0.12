cmake_minimum_required(VERSION 3.17)

project(math C)

set(LIB_NAME math)

set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

add_library(${LIB_NAME} STATIC math_emulate.c)
target_compile_options(${LIB_NAME} PUBLIC ${GCCFLAGS})
target_include_directories(${LIB_NAME} PUBLIC "${INCLUDE_DIR}")
