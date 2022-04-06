include(../modules/default_proj.cmake)
default_exec(GAS_EXEC "${GAS_EXEC}" "as")
SET(CMAKE_ASM_GAS_COMPILER "${GAS_EXEC}")
