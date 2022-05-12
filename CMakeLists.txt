cmake_minimum_required(VERSION 3.16)

set(SOURCE_ROOT_DIR "${CMAKE_SOURCE_DIR}")
set(BINARY_ROOT_DIR "${CMAKE_BINARY_DIR}")
set(INCLUDE_DIR "${SOURCE_ROOT_DIR}/include")

################################
###### Default Executable ######
################################

include(modules/default_proj.cmake)

default_exec(QEMU_EXEC      "${QEMU_EXEC}"      "qemu-system-i386")
default_exec(DD_EXEC        "${DD_EXEC}"        "dd")
default_exec(CP_EXEC        "${CP_EXEC}"        "cp")
default_exec(GAS_EXEC       "${GAS_EXEC}"       "as")
default_exec(GLD_EXEC       "${GLD_EXEC}"       "ld")
default_exec(STRIP_EXEC     "${STRIP_EXEC}"     "strip")
default_exec(OBJCPY_EXEC    "${OBJCPY_EXEC}"    "objcopy")
default_exec(NM_EXEC        "${NM_EXEC}"        "nm")
default_exec(GREP_EXEC      "${GREP_EXEC}"      "grep")
default_exec(SORT_EXEC      "${SORT_EXEC}"      "sort")
default_exec(RM_EXEC        "${RM_EXEC}"        "rm")

default_flags(ADDITIONAL_QEMU_FLAG "${ADDITIONAL_QEMU_FLAG}"    "")
default_flags(GAS_FLAGS         "${GAS_FLAGS}"          "--32 -g")
default_flags(GAS_LDFLAGS       "${GAS_LDFLAGS}"        "-m elf_i386 -g")
default_flags(GCCFLAGS          "${GCCFLAGS}"           "-m32 -fno-builtin \
                                                         -fno-stack-protector \
                                                         -fomit-frame-pointer \
                                                         -fstrength-reduce -Wall -g")
default_flags(HDC_DISK_IMG      "${HDC_DISK_IMG}"       "hdc-0.11.img")

string(REPLACE " " ";" ADDITIONAL_QEMU_FLAG    "${ADDITIONAL_QEMU_FLAG}")
string(REPLACE " " ";" GAS_FLAGS    "${GAS_FLAGS}")
string(REPLACE " " ";" GAS_LDFLAGS  "${GAS_LDFLAGS}")
string(REPLACE " " ";" GCCFLAGS     "${GCCFLAGS}")

################################
#########  Output Name #########
################################
default_flags(KERNEL_NAME "${KERNEL_NAME}" "linux")
default_flags(FLOPPY_IMG_NAME "${FLOPPY_IMG_NAME}" "floppy.img")

################################
###### Proj Configuration ######
################################

project(${KERNEL_NAME})

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

set(TMP_KERNEL_NAME "${KERNEL_NAME}.kernel.elf32")

# compile kernel with debug information
add_custom_target(${TMP_KERNEL_NAME} ALL
        COMMAND "${GLD_EXEC}" ${GAS_LDFLAGS} -Ttext 0 -e startup_32
                boot/libhead.a init/libinit.a kernel/libkernel.a mm/libmm.a
                fs/libfs.a kernel/blk_drv/libblk_drv.a kernel/chr_drv/libchr_drv.a
                kernel/math/libmath.a lib/liblib.a
                -o
                "${TMP_KERNEL_NAME}"
        DEPENDS head fs kernel mm init lib chr_drv blk_drv math
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# generate system symbol map
add_custom_target(System.map ALL
        COMMAND "${NM_EXEC}" "${TMP_KERNEL_NAME}"
        | ${GREP_EXEC} -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'
        | ${SORT_EXEC} > System.map
        DEPENDS ${TMP_KERNEL_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# strip boot sector
add_custom_target(strip_bootsect ALL
        COMMAND ${CMAKE_SOURCE_DIR}/script/strip_bootsect.sh boot/bootsect ${OBJCPY_EXEC} ${DD_EXEC} ${RM_EXEC}
        DEPENDS bootsect
        BYPRODUCTS bootsect.bin
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# strip setup
add_custom_target(strip_setup ALL
        COMMAND ${CMAKE_SOURCE_DIR}/script/strip_setup.sh boot/setup ${OBJCPY_EXEC} ${DD_EXEC} ${RM_EXEC}
        DEPENDS setup
        BYPRODUCTS setup.bin
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# generate pure binary kernel
add_custom_target(${KERNEL_NAME} ALL
        # generate kernel
        COMMAND ${OBJCPY_EXEC} -O binary -R .note -R .comment "${TMP_KERNEL_NAME}" ${KERNEL_NAME}.raw
        #                                                                       2880 - 1(bootsect) - 3(setup)
        COMMAND ${DD_EXEC} if=${KERNEL_NAME}.raw of=${KERNEL_NAME} bs=512 count=2876 2> /dev/null > /dev/null
        COMMAND ${RM_EXEC} ${KERNEL_NAME}.raw
        DEPENDS ${TMP_KERNEL_NAME}
        )

# generate floppy image
add_custom_target(${FLOPPY_IMG_NAME} ALL
        # boot sector
        COMMAND "${DD_EXEC}" if=boot/bootsect.bin bs=512 count=1 of=${FLOPPY_IMG_NAME} 2> /dev/null > /dev/null
        # setup
        COMMAND "${DD_EXEC}" if=boot/setup.bin seek=1 bs=512 count=4 of=${FLOPPY_IMG_NAME} 2> /dev/null > /dev/null
        # System                                                   2875 == 2880 -1 -4
        COMMAND "${DD_EXEC}" if=${KERNEL_NAME} seek=5 bs=512 count=2875 of=${FLOPPY_IMG_NAME} 2> /dev/null > /dev/null
        DEPENDS ${KERNEL_NAME} strip_bootsect strip_setup
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# qemu debugging
add_custom_target(qemu_debug
        # Make a copy of the root hdd
        COMMAND ${CP_EXEC} ../${HDC_DISK_IMG} ${HDC_DISK_IMG}
        # boot qemu
        COMMAND ${QEMU_EXEC} ${ADDITIONAL_QEMU_FLAG} -boot a
                -blockdev driver=file,node-name=fda,filename=${FLOPPY_IMG_NAME}
                -device floppy,drive=fda -drive format=raw,file=${HDC_DISK_IMG}
                -m 16M -S -gdb tcp:0.0.0.0:9000
        DEPENDS ${FLOPPY_IMG_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

# qemu boot
add_custom_target(qemu_boot
        # Make a copy of the root hdd
        COMMAND ${CP_EXEC} ../${HDC_DISK_IMG} ${HDC_DISK_IMG}
        # boot qemu
        COMMAND ${QEMU_EXEC} ${ADDITIONAL_QEMU_FLAG} -boot a
        -blockdev driver=file,node-name=fda,filename=${FLOPPY_IMG_NAME}
        -device floppy,drive=fda -drive format=raw,file=${HDC_DISK_IMG}
        -m 16M
        DEPENDS ${FLOPPY_IMG_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
