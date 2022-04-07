MESSAGE("Building for Intel 80386 platform...")
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

include(../modules/default_proj.cmake)
default_exec(AS_EXEC "${AS_EXEC}" "as")
SET(CMAKE_AS_COMPILER "${AS_EXEC}")
