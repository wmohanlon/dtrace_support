#pragma D option quiet
#pragma D option switchrate=25hz

int last[int];

dtrace:::BEGIN
{
        printf("   %12s %-20s    %-20s %s\n",
            "DELTA(us)", "OLD", "NEW", "TIMESTAMP");
}

tcp:::state-change
{
        this->elapsed = (timestamp - last[args[1]->cs_cid]) / 1000;
        printf("   %12d %-20s -> %-20s %16s:%-5d %16s:%-5d %Y\n", this->elapsed / (1000*1000),
            tcp_state_string[args[5]->tcps_state],
            tcp_state_string[args[3]->tcps_state], 
                args[3]->tcps_raddr, args[3]->tcps_rport, 
                args[3]->tcps_laddr, args[3]->tcps_lport, 
                walltimestamp);
        last[args[1]->cs_cid] = timestamp;
}

tcp:::state-change
/last[args[1]->cs_cid] == 0/
{
        printf("   %12s %-20s -> %-20s %16s:%-5d %16s:%-5d %Y\n", "-",
            tcp_state_string[args[5]->tcps_state],
            tcp_state_string[args[3]->tcps_state], 
                args[3]->tcps_raddr, args[3]->tcps_rport, 
                args[3]->tcps_laddr, args[3]->tcps_lport, 
                        walltimestamp);
        last[args[1]->cs_cid] = timestamp;
}

