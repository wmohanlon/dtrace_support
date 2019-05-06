#!/usr/sbin/dtrace -s

syscall::read:entry
/fds[arg0].fi_fs == "zfs"/
{
	self->start = timestamp;
}

syscall::read:return
/self->start/
{
	@[execname, "(ns):"] = quantize(timestamp - self->start);
	self->start = 0;
}
