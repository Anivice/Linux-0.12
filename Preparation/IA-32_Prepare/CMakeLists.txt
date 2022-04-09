cmake_minimum_required(VERSION 3.17)

# setup gas
LIST(APPEND CMAKE_MODULE_PATH "${SOURCE_ROOT_DIR}/modules")
include("${SOURCE_ROOT_DIR}/modules/setup_gas.cmake")

project(boot ASM_AS)

function(add_single_file diskname)
    # Compile boot sector
    set_source_files_properties(${diskname}.s PROPERTIES LANGUAGE ASM_AS)
    add_executable(${diskname} ${diskname}.s)
    target_compile_options(${diskname} PUBLIC --32 -g)
    target_link_options(${diskname} PUBLIC -Ttext 0 -m elf_i386 -g)

    # strip boot sector
    add_custom_target(strip_${diskname} ALL
            # Make a copy of current object
            COMMAND ${CP_EXEC} Preparation/IA-32_Prepare/${diskname}
                               Preparation/IA-32_Prepare/${diskname}.elf32
            COMMAND ${SOURCE_ROOT_DIR}/script/strip_bootsect.sh
                    Preparation/IA-32_Prepare/${diskname} ${OBJCPY_EXEC} ${DD_EXEC} ${RM_EXEC}
            DEPENDS ${diskname}
            WORKING_DIRECTORY ${BINARY_ROOT_DIR})

    # add QEMU boot
    add_custom_target(qemu_boot_${diskname}
            ${QEMU_EXEC} -drive file=Preparation/IA-32_Prepare/${diskname},format=raw,index=0,media=disk -m 16M
            DEPENDS strip_${diskname}
            WORKING_DIRECTORY ${BINARY_ROOT_DIR})
endfunction()

add_single_file(simple_bootsect)
add_single_file(advanced_bootsect)
add_single_file("1+2+...+100")
