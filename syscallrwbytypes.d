#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10hz
#pragma D option bufsize=8m
#pragma D option dynvarsize=8m

/*
 * We first define the types here. Refer to <sys/file.h>.
 * Note that I have define some new types to distingush
 * between AF_UNIX (Unix domain socket) and AF_INET.
 */

BEGIN
{
        ftype[1,0] = "File";
        ftype[2,0] = "Socket";
        ftype[3,0] = "Pipe";
        ftype[4,0] = "Fifo";
        ftype[5,0] = "Event queue";
        ftype[6,0] = "Crypto";
        ftype[7,0] = "Messages queue";
        ftype[8,0] = "Shm";
        ftype[9,0] = "Semaphore";
        ftype[10,0] = "PTY";
        ftype[11,0] = "dev";
        ftype[2,1] = "AF_UNIX";
        ftype[2,2] = "AF_INET";
        ftype[2,28] = "AF_INET6";
}

syscall::read:entry, syscall::pread:entry,
syscall::readv:entry, syscall::preadv:entry,
syscall::write:entry, syscall::pwrite:entry,
syscall::writev:entry, syscall::pwritev:entry,
syscall::recvfrom:entry, syscall::recvmsg:entry,
syscall::sendto:entry, syscall::sendmsg:entry
{
        this->fp = curthread->td_proc->p_fd->fd_ofiles[arg0];
        self->fi_type[stackdepth] = this->fp != 0 ? this->fp->f_type : -1;
        @entry[ftype[self->fi_type[stackdepth], 0]] = count();
        self->ts[stackdepth] = timestamp;
}

/* Here we distinguish between AF_UNIX and AF_INET. */

syscall::read:entry, syscall::pread:entry,
syscall::readv:entry, syscall::preadv:entry,
syscall::write:entry, syscall::pwrite:entry,
syscall::writev:entry, syscall::pwritev:entry,
syscall::recvfrom:entry, syscall::recvmsg:entry,
syscall::sendto:entry, syscall::sendmsg:entry
/self->fi_type[stackdepth] == 2/
{
        this->sp = (struct socket *)this->fp->f_data;
        self->family[stackdepth] = this->sp->so_proto->pr_domain->dom_family;
}

syscall::read:return, syscall::pread:return,
syscall::readv:return, syscall::preadv:return,
syscall::recvfrom:return, syscall::recvmsg:return
/this->delta = timestamp - self->ts[stackdepth]/
{
        this->rw = "Read";  /* These are reads. */
}

syscall::write:return, syscall::pwrite:return,
syscall::writev:return, syscall::pwritev:return,
syscall::sendto:return, syscall::sendmsg:return
/this->delta = timestamp - self->ts[stackdepth]/
{
        this->rw = "Write";  /* These are writes. */
}

syscall::read:return, syscall::pread:return,
syscall::readv:return, syscall::preadv:return,
syscall::recvfrom:return, syscall::recvmsg:return,
syscall::write:return, syscall::pwrite:return,
syscall::writev:return, syscall::pwritev:return,
syscall::sendto:return, syscall::sendmsg:return
/self->ts[stackdepth]/
{
        this->type = self->fi_type[stackdepth];
        this->family = self->family[stackdepth];
        @return[ftype[this->type, this->family]] = count();
        this->bytes = (arg1 != -1) ? arg1 : 0;
        @lat[ftype[this->type, this->family], this->rw] = quantize(this->delta);
        @bytes[ftype[this->type, this->family], this->rw] = quantize(this->bytes);
        @sum[ftype[this->type, this->family], this->rw] = sum(this->bytes);
}

syscall::read:return, syscall::pread:return,
syscall::readv:return, syscall::preadv:return,
syscall::recvfrom:return, syscall::recvmsg:return,
syscall::write:return, syscall::pwrite:return,
syscall::writev:return, syscall::pwritev:return,
syscall::sendto:return, syscall::sendmsg:return
{
        self->ts[stackdepth] = 0;
        self->fi_type[stackdepth] = 0;
        self->family[stackdepth] = 0;
}

tick-1s
{
        printf("%-15s %8s\n", "FILE TYPE", "COUNT");
        printa("%-15s %8@d\n", @return);
        /* Uncomment to check the numbers add up. */
        /* printa("%-15s %8@d\n", @entry); */
        printf("\nLatancies in ns:\n");
        printa(@lat);
        printf("\nFile sizes in bytes:\n");
        printa(@bytes);
        printf("\n\n%-15s %-5s %15s\n", "FILE TYPE", "OPS", "SUM (in bytes)");
        printa("%-15s %-5s %15@d\n", @sum);
        printf("\n------------------------------------------------------------\n");
        trunc(@entry); trunc(@return); trunc(@sum); trunc(@lat); trunc(@bytes);
}
