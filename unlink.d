#!/usr/sbin/dtrace -s

#pragma D option destructive

syscall::unlink:entry 
/execname == "smbd"/
{
   printf("%s %d %s     ", execname, pid, copyinstr(arg0));
   system("smbstatus -p | grep %d", pid);
   system("smbstatus -p | grep %d | logger", pid);
}
