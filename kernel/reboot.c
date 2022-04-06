#include <linux/errno.h>

int sys_reboot(int command)
{
    return -ENOSYS;
}
