         #pragma D option quiet
           #pragma D option switchrate=25hz

           int last[int];

           dtrace:::BEGIN
           {
                   printf("   %12s %-20s    %-20s %s %s\n",
                       "DELTA(us)", "OLD", "NEW", "TIMESTAMP", "PORT");
           }

           tcp:::state-change
           {
                   this->elapsed = (timestamp - last[args[1]->cs_cid]) / 1000;
                   printf("   %12d %-20s -> %-20s %d %d\n", this->elapsed,
                       tcp_state_string[args[5]->tcps_state],
                       tcp_state_string[args[3]->tcps_state], timestamp, args[3]->tcps_lport);
                   last[args[1]->cs_cid] = timestamp;
           }

           tcp:::state-change
           /last[args[1]->cs_cid] == 0/
           {
                   printf("   %12s %-20s -> %-20s %d %d\n", "-",
                       tcp_state_string[args[5]->tcps_state],
                       tcp_state_string[args[3]->tcps_state], timestamp, args[3]->tcps_lport);
                   last[args[1]->cs_cid] = timestamp;
           }
