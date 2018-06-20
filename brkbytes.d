#!/usr/sbin/dtrace -s

inline string target = "firefox";
uint brk[int];

syscall::sbrk:entry /execname == target/ { self->p = arg0; }
syscall::sbrk:return /arg0 == 0 && self->p && brk[pid]/ {
	@[ustack()] = sum(self->p - brk[pid]);
}
syscall::sbrk:return /arg0 == 0 && self->p/ { brk[pid] = self->p; }
syscall::sbrk:return /self->p/ { self->p = 0; }
