syscall::open:entry 
/execname=="minio"/
{
/*   printf("%s %s", execname, copyinstr(arg0)); */
self->fname = arg0;
}
 syscall::openat:entry
/execname=="minio"/
{
        printf("%s %s", execname, copyinstr(arg1));
self->fname = arg0;
}

syscall::open:return
/execname=="minio"/
{
  printf("%s %s", execname, copyinstr(self->fname));
}
