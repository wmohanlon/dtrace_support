#!/usr/sbin/dtrace -s

::nfssvc_idname:entry
{
	self->nidp = (struct nfsd_idargs *)arg0;

	print(*self->nidp);

	printf("nnid_name=%s nid_namelen=%d\n", copyinstr((uintptr_t)self->nidp->nid_name), self->nidp->nid_namelen);
}
