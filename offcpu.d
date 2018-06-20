#!/usr/sbin/dtrace -s
/*
 * offcpu.d	Trace off-CPU time and emit in folded format for flame graphs.
 *
 * See the sched:::off-cpu predicate, which currently filters on "bsdtar"
 * processes only. Change/remove as desired. This program traces all off-CPU
 * events, including involuntary context switch preempts.
[...]
 * 23-Sep-2017	Brendan Gregg	Created this.
 */

#pragma D option ustackframes=100
#pragma D option dynvarsize=32m

/*
 * Customize the following predicate as desired.
 * eg, you could add /curthread->td_state <= 1/ to exclude preempt paths and
 * involuntary context switches, which are interesting but their stacks usually
 * aren't. The "1" comes from td_state for TDS_INHIBITED. See sys/proc.h.
 *
 */

sched:::off-cpu /execname == "firefox"/ { self->ts = timestamp; }

sched:::on-cpu
/self->ts/
{
	@[stack(), ustack(), execname] = sum(timestamp - self->ts);
	self->ts = 0;
}

dtrace:::END
{
	normalize(@, 1000000);
	printa("%k-%k%s\n%@d\n", @);
}

