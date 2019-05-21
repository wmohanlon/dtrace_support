#!/usr/sbin/dtrace -s

tcp:::connect-request
{
        start[arg0] = timestamp;
}

tcp:::connect-established
/start[arg0]/
{
        @latency["Connect Latency (ns)", args[2]->ip_daddr] =
            quantize(timestamp - start[arg0]);
        start[arg0] = 0;
}
