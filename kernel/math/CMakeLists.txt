project(math C)

add_library(math STATIC math_emulate.c)
target_compile_options(math PUBLIC ${GCCFLAGS})
target_include_directories(math PUBLIC "${INCLUDE_DIR}")
