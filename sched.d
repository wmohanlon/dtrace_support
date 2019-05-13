sched:::on-cpu
{
        self->ts = timestamp;
}

sched:::off-cpu
/self->ts != 0/
{
        @[execname] = sum((timestamp - self->ts) / 1000);
        self->ts = 0;
}

