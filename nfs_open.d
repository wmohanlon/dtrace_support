*:*:nfsrv_parsename:entry
{
   self->file = arg1;
}
*:*:nfsrv_parsename:return
{
   printf("%Y %s %s", walltimestamp, execname, stringof(self->file));
   self->file = 0;
}

