#!/usr/sbin/dtrace -s

/* syscall::*read:entry, */
syscall::*write:entry
/execname != "dtrace" && execname != "sshd"/
{
    /* printf("%5d %s CALL %s(%d, .., %d)", pid, execname, probefunc, arg0, arg2);*/
    self->fd = arg0;
}

/* syscall::*readv:entry, */
syscall::*writev:entry
/execname != "dtrace" && execname != "sshd"/
{
     /*printf("%5d %s CALL %s(%d, ...)", pid, execname, probefunc, arg0);*/
}

/* syscall::*read*:return 
/execname != "dtrace" && execname != "sshd"/
{
    printf("%5d %s fd %d read %d bytes", pid, execname, self->fd, arg0);
    self->fd = 0;
} */

syscall::*write*:return
/execname != "dtrace" && execname != "sshd"/
{
    printf("%5d %s fd %d wrote %d bytes", pid, execname, self->fd, arg0);
    self->fd = 0;
}
