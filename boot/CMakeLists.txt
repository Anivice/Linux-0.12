cmake_minimum_required(VERSION 3.17)

project(boot)

function(add_single_file_target target_name comment LINKREQUIRED)
    set(OUTPUT_OBJNAME  "${target_name}.o")
    set(OUTPUT_FILENAME "${target_name}")
    set(INPUT_FILENAME  "${SOURCE_ROOT_DIR}/boot/${target_name}.s")

    if (${LINKREQUIRED} STREQUAL "TRUE")
        add_custom_target(
            ${target_name} ALL
            COMMAND "${GAS_EXEC}" ${GAS_FLAGS} -o "${OUTPUT_OBJNAME}"
                                                  "${INPUT_FILENAME}"           
            COMMAND "${GLD_EXEC}" -Ttext 0 ${GAS_LDFLAGS}
                                                 -o "${OUTPUT_FILENAME}"
                                                    "${OUTPUT_OBJNAME}"         
            COMMAND "${OBJCPY_EXEC}" -R .pdr -R .comment -R .note -S -O binary
                                                    "${OUTPUT_FILENAME}"        
            BYPRODUCTS "${OUTPUT_FILENAME}" "${OUTPUT_OBJNAME}"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/boot"
            COMMENT "${comment}")
    else()
        add_custom_target(
            ${target_name} ALL
            COMMAND "${GAS_EXEC}" ${GAS_FLAGS} -o "${OUTPUT_OBJNAME}"
                                                  "${INPUT_FILENAME}"           
            BYPRODUCTS "${OUTPUT_OBJNAME}"
            WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/boot"
            COMMENT "${comment}")
    endif()
endfunction()

add_single_file_target(bootsect "Building boot sector" "TRUE")
add_single_file_target(setup    "Building setup"       "TRUE")
add_single_file_target(head     "Building head"        "FALSE")

set(BOOT_OBJECTS bootsect setup head PARENT_SCOPE)
