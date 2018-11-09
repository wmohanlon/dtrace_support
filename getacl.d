syscall::*getacl:entry 
{
   printf("%s %s", execname, copyinstr(arg0));
}
