#pragma D option quiet
#pragma D option destructive
#pragma D option switchrate=10hz


fbt:kernel:sonewconn:entry
{
	self->head = (struct socket *)arg0;
	this->on = 0;
}

fbt:kernel:sonewconn:return
/args[1] == 0/
{
	this->on = 1;
        p = (struct inpcb *)self->head->so_pcb;
        this->pcb = (struct inpcb *)self->head->so_pcb;
}

dtrace:::BEGIN
{
        printf("Time                            PCB      DADDR:SPORT\n");
}

tcp:::accept-refused
/args[4]->tcp_flags & TH_RST && this->on == 1 && args[4] == this->pcb/
{
	@a[this->pcb, args[2]->ip_daddr, args[4]->tcp_sport] = count();
        printf("\n");
}

tick-60sec 
{
	printf("%Y ", walltimestamp);
	printa("%p %16s:%d", @a);
	printf("\n");
	trunc(@a);
}
