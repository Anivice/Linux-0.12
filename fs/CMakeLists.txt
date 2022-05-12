project(fs C)

add_library(fs STATIC
        bitmap.c block_dev.c buffer.c char_dev.c exec.c fcntl.c file_dev.c
        file_table.c inode.c ioctl.c namei.c open.c pipe.c read_write.c stat.c super.c truncate.c)
target_include_directories(fs PUBLIC "${INCLUDE_DIR}")
target_compile_options(fs PUBLIC ${GCCFLAGS})
