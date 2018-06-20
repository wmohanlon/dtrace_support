syscall::open:entry 
{
   printf("%s %s", execname, copyinstr(arg0));
}
 syscall::openat:entry
{
        printf("%s %s", execname, copyinstr(arg1));
}
