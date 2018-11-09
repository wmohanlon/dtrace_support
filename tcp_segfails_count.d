          #pragma D option quiet
           #pragma D option switchrate=10hz

           dtrace:::BEGIN
           {
          /*         printf(" %3s %15s:%-5s      %15s:%-5s %6s  %s\n", "CPU",
                       "LADDR", "LPORT", "RADDR", "RPORT", "BYTES", "FLAGS"); */
           }

           tcp:::receive
	   /args[4]->tcp_flags & TH_RST/
           {
		   thing = strjoin(args[2]->ip_saddr, ":");
		    
		   /* strjoin(lltostr(this->a[0] + 0ULL) */
		   thing = strjoin(thing, lltostr(args[4]->tcp_dport + 0ULL));
                   @saddrs[thing] = count();
           }

profile:::tick-60sec,
dtrace:::END
{
	printf("Time: %Y", walltimestamp);

	printa(@saddrs);
	trunc(@saddrs);
}
