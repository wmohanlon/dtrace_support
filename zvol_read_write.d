#!/usr/sbin/dtrace -s

#pragma D option destructive

fbt:kernel:zvol_read:entry,
fbt:kernel:zvol_write:entry
{
   this->buf = (struct cdev *)arg0;
   printf("%s %d %s\n", execname, pid, this->buf->si_name);
}

fbt:kernel:zvol_d_open:entry,
fbt:kernel:zvol_d_close:entry
{
   printf("%s %d\n", execname, pid);
}
