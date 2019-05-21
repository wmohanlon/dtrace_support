#!/usr/sbin/dtrace -qs

dtrace:::BEGIN
{
        printf("Tracing... Hit Ctrl-C to end.\n");
}

tcp:::accept-established
{
        @num[args[1]->ip_saddr, args[2]->tcp_dport] = count();
}

dtrace:::END
{
        printf("   %-26s %-8s %8s\n", "HOSTNAME", "PORT", "COUNT");
        printa("   %-26I %-8P %@8d\n", @num);
}
