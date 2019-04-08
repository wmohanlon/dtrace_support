*:*:nfsrv_parsename:entry
{
   self->file = arg1;
}
*:*:nfsrv_parsename:return
{
   printf("%s %s", execname, stringof(self->file));
   self->file = 0;
}

