#pragma D option destructive

syscall::unlink*:entry 
{
   printf("%s (%d) %s", execname, pid, copyinstr(arg0)); 
   system("ps -auxwww -p %d | grep -v 'USER.*PID'  ", pid);
   system("ps -auxwww -p %d | grep -v 'USER.*PID' | sed 's#^#unlinked %s #' | logger -p user.crit", pid, copyinstr(arg0));
}
