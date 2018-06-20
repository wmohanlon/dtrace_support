#!/usr/sbin/dtrace -s

fbt::nfsrv_checkuidgid:entry
{
	this->va_uid = args[1]->na_vattr.va_uid;
print(*(args[0]));
	printf("na_uid %d", this->va_uid);
}
fbt::nfsrv_checkuidgid:return
{ 
	/* printf("XXXX %d", *((struct nfsvattr *)self->na)->na_uid); */
}

::nfsv4_strtouid:entry
{
	self->nd = (struct nfsrv_descript *)arg0;
	self->str = arg1;
	self->uidp = arg3;
	self->len = arg2;

/* 	printf("len=%d, str=%s", arg2, stringof(arg1)); */
print(*(args[0]));
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

::nfssvc_idname:entry
{
	self->nidp = (struct nfsd_idargs *)arg0;

/*
	print(*self->nidp);
*/

print(*(args[0]));

	printf("nnid_name=%s nid_namelen=%d\n", copyinstr((uintptr_t)self->nidp->nid_name), self->nidp->nid_namelen);
}

