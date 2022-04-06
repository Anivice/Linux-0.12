MESSAGE("Building for Intel 80386 platform...")
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

include(../modules/default_proj.cmake)
default_exec(GAS_EXEC "${GAS_EXEC}" "as")
SET(CMAKE_GAS_COMPILER "${GAS_EXEC}")
