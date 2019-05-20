#pragma D option quiet
#pragma D option destructive
#pragma D option switchrate=10hz


fbt:kernel:sonewconn:entry
{
	self->head = (struct socket *)arg0;
	this->on = 1;
}

fbt:kernel:sonewconn:return
/args[1] == 0/
{
	this->on = 0;
	printf("%Y qlen = %d\n", walltimestamp, self->head->so_qlen);
	system("netstat -Lan -4 |  tail -n +3 | grep -v 'tcp4  0/0'"); 
}

dtrace:::BEGIN
{
        printf("Time                   %3s %12s:%-5s   %15s:%-5s     %6s  %s\n", "CPU",
            "LADDR", "LPORT", "RADDR", "RPORT", "BYTES", "FLAGS");
}

tcp:::send
/args[4]->tcp_flags & TH_RST && this->on == 1/
{
        this->length = args[2]->ip_plength - args[4]->tcp_offset;
        printf("%Y %3d %16s:%-5d SEND %16s:%-5d %6d  (", walltimestamp, cpu, args[2]->ip_saddr,
            args[4]->tcp_sport, args[2]->ip_daddr, args[4]->tcp_dport,
            this->length);
        printf("%s", args[4]->tcp_flags & TH_FIN ? "FIN|" : "");
        printf("%s", args[4]->tcp_flags & TH_SYN ? "SYN|" : "");
        printf("%s", args[4]->tcp_flags & TH_RST ? "RST|" : "");
        printf("%s", args[4]->tcp_flags & TH_PUSH ? "PUSH|" : "");
        printf("%s", args[4]->tcp_flags & TH_ACK ? "ACK|" : "");
        printf("%s", args[4]->tcp_flags & TH_URG ? "URG|" : "");
        printf("%s", args[4]->tcp_flags == 0 ? "null " : "");
        printf("\n");
}

tcp:::receive
/args[4]->tcp_flags & TH_RST && this->on == 1/
{
        this->length = args[2]->ip_plength - args[4]->tcp_offset;
        printf("%Y %3d %16s:%-5d RECV %16s:%-5d %6d  (", walltimestamp, cpu,
            args[2]->ip_daddr, args[4]->tcp_dport, args[2]->ip_saddr,
            args[4]->tcp_sport, this->length);
        printf("%s", args[4]->tcp_flags & TH_FIN ? "FIN|" : "");
        printf("%s", args[4]->tcp_flags & TH_SYN ? "SYN|" : "");
        printf("%s", args[4]->tcp_flags & TH_RST ? "RST|" : "");
        printf("%s", args[4]->tcp_flags & TH_PUSH ? "PUSH|" : "");
        printf("%s", args[4]->tcp_flags & TH_ACK ? "ACK|" : "");
        printf("%s", args[4]->tcp_flags & TH_URG ? "URG|" : "");
        printf("%s", args[4]->tcp_flags == 0 ? "null " : "");
        printf("\n");
}

