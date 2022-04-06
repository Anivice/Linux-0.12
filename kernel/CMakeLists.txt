cmake_minimum_required(VERSION 3.17)

project(kernel C ASM)

add_subdirectory(blk_drv)
add_subdirectory(chr_drv)
add_subdirectory(math)

add_library(kernel STATIC
        sched.c traps.c fork.c panic.c printk.c
        vsprintf.c sys.c exit.c signal.c
        mktime.c sys_inf.c reboot.c
        asm.s system_call.s)
target_include_directories(kernel PUBLIC "${INCLUDE_DIR}")
target_compile_options(kernel PUBLIC ${GCCFLAGS})
