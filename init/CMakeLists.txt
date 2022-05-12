project(init C)

add_library(init STATIC main.c)
target_compile_options(init PUBLIC ${GCCFLAGS})
target_include_directories(init PUBLIC "${INCLUDE_DIR}")
