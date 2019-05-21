#!/usr/sbin/dtrace -s

tcp:::connect-established
{
        start[arg0] = timestamp;
}

tcp:::receive
/start[arg0] && (args[2]->ip_plength - args[4]->tcp_offset) > 0/
{
        @latency["1st Byte Latency (ns)", args[2]->ip_saddr] =
            quantize(timestamp - start[arg0]);
        start[arg0] = 0;
}
