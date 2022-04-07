cmake_minimum_required(VERSION 3.17)

# setup gas
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../modules")
include("${CMAKE_CURRENT_SOURCE_DIR}/../modules/setup_gas.cmake")

project(boot ASM_GAS)

# Compile boot sector
set_source_files_properties(bootsect.s PROPERTIES LANGUAGE ASM_GAS)
add_executable(bootsect bootsect.s)
target_compile_options(bootsect PRIVATE "--32")
target_link_options(bootsect PUBLIC -Ttext 0 -m elf_i386)

# Compile setup
set_source_files_properties(setup.s PROPERTIES LANGUAGE ASM_GAS)
add_executable(setup setup.s)
target_compile_options(setup PRIVATE "--32")
target_link_options(setup PUBLIC -Ttext 0 -m elf_i386)

# Compile head
set_source_files_properties(head.s PROPERTIES LANGUAGE ASM_GAS)
add_library(head STATIC head.s)
target_compile_options(head PRIVATE --32 -g)
