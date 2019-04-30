#!/usr/sbin/dtrace -s

/*
 * vfsstat emulation
 */

#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=10hz
#pragma D option bufsize=8m
#pragma D option dynvarsize=32m

/*
 * Refer to man 9 VFS and the files <sys/vnode.h>,
 * </usr/src/sys/kern/vfs_default.c> and various
 * information on vnode in each fs.
 */

/*
 * This script only records successful operations. However, it
 * is trivial to modify so that failures are also record.
 * This script is intent to be used with your favourite scripting
 * language to process the output into something like the
 * Solaris fsstat. Also, note that read and write bytes will
 * be significantly different with disk IOs due to IO inflation
 * or deflation.
 */

vfs::vop_read:entry, vfs::vop_write:entry
{
        self->bytes[stackdepth] = args[1]->a_uio->uio_resid;
}

vfs::vop_read:return, vfs::vop_write:return
/this->delta = self->bytes[stackdepth] - args[1]->a_uio->uio_resid/
{
        this->fi_mount = args[0]->v_mount ?
                stringof(args[0]->v_mount->mnt_stat.f_mntonname) :
                        "<none>";
        @bytes[this->fi_mount, probefunc] = sum(this->delta);
        @ops[this->fi_mount, probefunc] = count();
}

vfs::vop_read:return, vfs::vop_write:return
{
        self->bytes[stackdepth] = 0;
}

/* You may add or remove operations of interest here. */

vfs::vop_rename:return, vfs::vop_create:return, vfs::vop_remove:return,
vfs::vop_getattr:return, vfs::vop_access:return, vfs::vop_open:return,
vfs::vop_close:return, vfs::vop_setattr:return, vfs::vop_rename:return,
vfs::vop_mkdir:return, vfs::vop_rmdir:return, vfs::vop_readdir:return,
vfs::vop_lookup:return, vfs::vop_cachedlookup:return
/errno == 0/
{
        this->fi_mount = args[0]->v_mount ?
                stringof(args[0]->v_mount->mnt_stat.f_mntonname) :
                        "<none>";
        @ops[this->fi_mount, probefunc] = count();
}

tick-1s
{
        printf("Number of operations\n");
        printf("%-40s %-18s %20s\n", "FILESYSTEM", "OPERATIONS", "COUNTS");
        printa("%-40s %-18s %20@d\n", @ops);
        printf("\nBytes read or write\n");
        printf("%-40s %-18s %20s\n", "FILESYSTEM", "OPERATIONS", "BYTES");
        printa("%-40s %-18s %20@d\n", @bytes);
        printf("\n--------------------------------------------------\n\n");
}
