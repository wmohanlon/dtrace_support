#pragma D option quiet
#pragma D option switchrate=10hz

dtrace:::BEGIN
{
        printf("TYPE           DATE            %15s:%-5s      %15s:%-5s\n",
            "LADDR", "LPORT", "RADDR", "RPORT");
}

tcp:::accept-refused
{
    this->length = args[2]->ip_plength - args[4]->tcp_offset;
    printf("ACCEPT-REFUSED %Y %16s:%-5d -> %16s:%-5d", walltimestamp, args[2]->ip_saddr,
            args[4]->tcp_sport, args[2]->ip_daddr, args[4]->tcp_dport);
    printf("\n");
}

tcp:::connect-refused
{
    this->length = args[2]->ip_plength - args[4]->tcp_offset;
    printf("CONNECT-REFUSED %Y %16s:%-5d <- %16s:%-5d ", walltimestamp, 
            args[2]->ip_daddr, args[4]->tcp_dport, args[2]->ip_saddr,
            args[4]->tcp_sport);
    printf("\n");
}
