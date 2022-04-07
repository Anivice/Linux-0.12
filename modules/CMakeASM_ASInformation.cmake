SET(ASM_DIALECT "_AS")

SET(CMAKE_ASM${ASM_DIALECT}_SOURCE_FILE_EXTENSIONS s;asm)

#Set any default arguments here
SET(CMAKE_ASM_AS_COMPILER_ARG1 "--32")

# This section exists to override the one in CMakeASMInformation.cmake
# (the default Information file). This removes the <FLAGS>
# thing so that your C compiler flags that have been set via
# set_target_properties don't get passed to TMPx and confuse it.
IF(NOT CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT)
    SET(CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT "<CMAKE_ASM${ASM_DIALECT}_COMPILER> -o <OBJECT> <SOURCE>")
ENDIF(NOT CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT)

INCLUDE(CMakeASMInformation)
SET(ASM_DIALECT)
