#!/usr/sbin/dtrace -s


::nfsv4_strtouid:entry
{
	self->nd = (struct nfsrv_descript *)arg0;
	self->str = arg1;
	self->uidp = arg3;
	self->len = arg2;

	printf("len=%d, str=%s", arg2, stringof(arg1));
/*
	print(*self->nd);
*/
}


::nfsv4_strtouid:return
{
	printf("uidp=%d ret=%d", *((int *)self->uidp), arg1);
}


::nfsv4_strtogid:entry
{
	self->nd = (struct nfsrv_descript *)arg0;
	self->str = arg1;
	self->len = arg2;
	self->gidp = arg3;

	printf("len=%d, str=%s", arg2, stringof(arg1));
}

::nfsv4_strtogid:return
{
	printf("gidp=%d ret=%d", *((int *)self->gidp), arg1)
}
