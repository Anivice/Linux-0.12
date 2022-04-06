cmake_minimum_required(VERSION 3.17)

project(math C)

add_library(math STATIC math_emulate.c)
target_compile_options(math PUBLIC ${GCCFLAGS})
target_include_directories(math PUBLIC "${INCLUDE_DIR}")
