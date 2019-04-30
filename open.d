syscall::open:entry 
{
/*   printf("%s %s", execname, copyinstr(arg0)); */
self->fname = arg0;
}
 syscall::openat:entry
{
        printf("%s %s", execname, copyinstr(arg1));
self->fname = arg0;
}

syscall::open:return
{
  printf("%s %s", execname, copyinstr(self->fname));
}
