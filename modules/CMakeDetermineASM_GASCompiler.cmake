SET(ASM_DIALECT "_GAS")
SET(CMAKE_ASM${ASM_DIALECT}_COMPILER_LIST ${_CMAKE_TOOLCHAIN_PREFIX}gas)

INCLUDE(CMakeDetermineASMCompiler)
SET(ASM_DIALECT)
