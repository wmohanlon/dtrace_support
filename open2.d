#!/usr/sbin/dtrace -s

dtrace:::BEGIN
{
    printf("%5s %5s %s","UID","PID", "Command  Path");
}

syscall::open*:entry
{
    printf("%5d %5d %s %s", uid, pid, execname,
                    probefunc == "open" ? copyinstr(arg0) : copyinstr(arg1));
}
