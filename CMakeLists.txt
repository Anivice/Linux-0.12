cmake_minimum_required(VERSION 3.17)

set(SOURCE_ROOT_DIR "${CMAKE_SOURCE_DIR}")
set(BINARY_ROOT_DIR "${CMAKE_BINARY_DIR}")

################################
###### Default Executable ######
################################

function(default_exec marco_name marco execname)
    if ("${marco}" STREQUAL "")
        find_program(${execname}_EXEC "${execname}" REQUIRED)
        message("Found executable `${execname}` (${${execname}_EXEC}). Manual override marco `${marco_name}`.")
        set(${marco_name} "${${execname}_EXEC}" PARENT_SCOPE)
    else()
        message("Executable `${execname}` overridden by `${marco}`.")
    endif()
endfunction()

function(default_flags marco_name marco flag_name)
    if ("${marco}" STREQUAL "")
        set(${marco_name} "${flag_name}" PARENT_SCOPE)
    endif()
endfunction()


default_exec(MKISOFS_EXEC   "${MKISOFS_EXEC}"   "mkisofs")
default_exec(DD_EXEC        "${DD_EXEC}"        "dd")
default_exec(MKDIR_EXEC     "${MKDIR_EXEC}"     "mkdir")
default_exec(TOUCH_EXEC     "${TOUCH_EXEC}"     "touch")
default_exec(CP_EXEC        "${CP_EXEC}"        "cp")
default_exec(GAS_EXEC       "${GAS_EXEC}"       "as")
default_exec(GLD_EXEC       "${GLD_EXEC}"       "ld")
default_exec(STRIP_EXEC     "${STRIP_EXEC}"     "strip")
default_exec(OBJCPY_EXEC    "${OBJCPY_EXEC}"    "objcopy")
default_exec(CPP_EXEC       "${CPP_EXEC}"       "cpp")
default_exec(NM_EXEC        "${NM_EXEC}"        "nm")
default_exec(GREP_EXEC      "${GREP_EXEC}"      "grep")
default_exec(SORT_EXEC      "${SORT_EXEC}"      "sort")
default_exec(RM_EXEC        "${RM_EXEC}"        "rm")

default_flags(OUTPUT_ISO_NAME   "${OUTPUT_ISO_NAME}"    "bootcd.iso")
default_flags(GAS_FLAGS         "${GAS_FLAGS}"          "--32")
default_flags(GAS_LDFLAGS       "${GAS_LDFLAGS}"        "-m elf_i386")
default_flags(GCCFLAGS          "${GCCFLAGS}"           "-m32 -fno-builtin \
                                                         -fno-stack-protector \
                                                         -fomit-frame-pointer \
                                                         -fstrength-reduce -Wall")
default_flags(GCXXFLAGS         "${GCXXFLAGS}"          "-nostdinc")
default_flags(HDC_DISK_IMG      "${HDC_DISK_IMG}"       "hdc-0.11.img")

string(REPLACE " " ";" GAS_FLAGS    "${GAS_FLAGS}")
string(REPLACE " " ";" GAS_LDFLAGS  "${GAS_LDFLAGS}")
string(REPLACE " " ";" GCCFLAGS     "${GCCFLAGS}")
string(REPLACE " " ";" GCXXFLAGS    "${GCXXFLAGS}")


################################
#########  Output Name #########
################################
default_flags(KERNEL_NAME "${KERNEL_NAME}" "Sysdarft")
default_flags(SYSTEM_IMG_NAME "${SYSTEM_IMG_NAME}" "Image")


################################
###### Verbose Output Ctl ######
################################

default_flags(VERBOSE "${VERBOSE}" "OFF")

if (NOT ${VERBOSE})
    set(CLEAN_CONSOLE "2>/dev/null" ">/dev/null")
else()
    set(CLEAN_CONSOLE "")
endif()


################################
###### Proj Configuration ######
################################

project(${KERNEL_NAME} C)


################################
####### Default Compilers ######
################################

# GCC 2.1 20201125 or higher is required for compile

if ((NOT ${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
        OR
    (${CMAKE_C_COMPILER_VERSION} VERSION_LESS 10.2.1))
    message(FATAL_ERROR "This kernel can ONLY be compiled by GCC 10.2.1 20201125 or higher")
endif()

set(CMAKE_C_STANDARD 11)


################################
###### Kernel Compilation ######
################################

add_subdirectory(boot)
add_subdirectory(fs)
add_subdirectory(kernel)
add_subdirectory(lib)
add_subdirectory(mm)
add_subdirectory(init)

set(ARCHIVES kernel/libkernel.a mm/libmm.a fs/libfs.a)
set(DRIVERS  kernel/blk_drv/libblk_drv.a kernel/chr_drv/libchr_drv.a)
set(MATH     kernel/math/libmath.a)
set(LIBS     lib/liblib.a)

set(TMP_KERNEL_NAME ".${KERNEL_NAME}.tmp")

add_custom_target(${KERNEL_NAME} ALL
        COMMAND "${GLD_EXEC}" ${GAS_LDFLAGS} -Ttext 0 -e startup_32
                boot/head.o
                init/CMakeFiles/init.dir/main.c.o
                ${ARCHIVES} ${DRIVERS} ${MATH} ${LIBS}
                -o
                "${TMP_KERNEL_NAME}"
        COMMAND "${NM_EXEC}" "${TMP_KERNEL_NAME}"
                |
                ${GREP_EXEC} -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'
                |
                ${SORT_EXEC}
                > System.map
        # strip
        COMMAND "${STRIP_EXEC}" "${TMP_KERNEL_NAME}"
        # generate kernel
        COMMAND ${OBJCPY_EXEC} -O binary -R .note -R .comment "${TMP_KERNEL_NAME}" "${KERNEL_NAME}"
        # remove temp files
        COMMAND ${RM_EXEC} -rf "${TMP_KERNEL_NAME}"
        DEPENDS ${BOOT_OBJECTS} fs kernel mm init lib chr_drv blk_drv math
        BYPRODUCTS "${KERNEL_NAME}" System.map
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Build system kernel '${KERNEL_NAME}'")

add_custom_target(Image ALL
        # boot sector
        COMMAND "${DD_EXEC}" if=boot/bootsect bs=512 count=1 of=${SYSTEM_IMG_NAME}              ${CLEAN_CONSOLE}
        # setup
        COMMAND "${DD_EXEC}" if=boot/setup seek=1 bs=512 count=4 of=${SYSTEM_IMG_NAME}          ${CLEAN_CONSOLE}
        # System                                                   2883 == 2888 -1 -4
        COMMAND "${DD_EXEC}" if=${KERNEL_NAME} seek=5 bs=512 count=2883 of=${SYSTEM_IMG_NAME}   ${CLEAN_CONSOLE}
        DEPENDS ${KERNEL_NAME}
        BYPRODUCTS ${SYSTEM_IMG_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Build system image '${SYSTEM_IMG_NAME}'")


################################
###### QEMU Configuration ######
################################

default_exec(QEMU_EXEC "${QEMU_EXEC}" "qemu-system-i386")

string(REPLACE " " ";" QEMU_HDD_OPTIONS   "${QEMU_HDD_OPTIONS}")
string(REPLACE " " ";" QEMU_CDROM_OPTIONS "${QEMU_CDROM_OPTIONS}")

add_custom_target(qemu_i386_emulation
        COMMAND "${QEMU_EXEC}"  -m 16M -boot a -blockdev
                                driver=file,node-name=fda,filename=${BINARY_ROOT_DIR}/${SYSTEM_IMG_NAME}
                                -device floppy,drive=fda -drive format=raw,file=${HDC_DISK_IMG}
                                -enable-kvm -m 128M ${QEMU_HDD_OPTIONS}
        DEPENDS ${KERNEL_NAME}
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        COMMENT "QEMU Boot from HDD")
