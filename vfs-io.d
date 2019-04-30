#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option bufsize=8m
#pragma D option switchrate=10hz
#pragma D option dynvarsize=16m

/* See /usr/src/sys/kern/uipc_mqueue.c for vop_read_args.
 * Also see sys/uio.h.
 */

vfs::vop_read:entry, vfs::vop_write:entry
{
        self->ts[stackdepth] = timestamp;
        this->size = args[1]->a_uio->uio_resid;
        this->name = probefunc == "vop_read" ? "Read" : "Write";
        @iosize1[execname, this->name] = quantize(this->size);
}

vfs::vop_read:return, vfs::vop_write:entry
/this->ts = self->ts[stackdepth]/
{
        this->name = probefunc == "vop_read" ? "Read" : "Write";
        @lat1[execname, this->name] = quantize(timestamp - this->ts);
        self->ts[stackdepth] = 0;
}

tick-1s
{
        printf("Latencies (ns)\n\n");
        printa("%s %s\n%@d\n", @lat1);
        printf("IO sizes (bytes)\n\n");
        printa("%s %s\n%@d\n", @iosize1);
        printf("--------------------------------------------\n\n");
        trunc(@lat1);
        trunc(@iosize1);
}
