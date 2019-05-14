#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10hz

/* Only devstat_start_transaction_bio corresponds to actual disk
 * io. Also, the following latency is only an approximation.
 * Since we use devstat.start_count as one of the key. A disk
 * may receive several requests before any io is completed on it.
 * So devstat.end_count may not corresponds to the original
 * request. For reference, see <sys/devicestat.h>.
 */

fbt::devstat_start_transaction_bio:entry
{
        dv[args[0], args[0]->start_count] = timestamp;
}

fbt::devstat_end_transaction:entry
/this->ts = dv[args[0], args[0]->end_count]/
{
        /* device_name corresponds to da, ada etc. args[3]
         * show whether the operation is read or write or
         * other. args[1] is the number of bytes read or
         * write. The start and end count let us check
         * whether there is some missing iops.
         */
        this->dn = stringof(args[0]->device_name);
        this->un = args[0]->unit_number;
        this->op = args[3] == 1 ? "Read" : args[3] == 2 ? "Write" : "Other";
        @lat[this->dn, this->un, this->op] = quantize((timestamp - this->ts) / (1000*1000));
        @qlen[this->dn, this->un, this->op] = quantize(args[0]->start_count - args[0]->end_count);
        dv[args[0], args[0]->end_count] = 0;
}

tick-10s
{
        printf("Latencies (ms)\n\n");
        printa("%s%d %s %@d\n", @lat);
        printf("Queue length\n\n");
        printa("%s%d %s %@d\n", @qlen);
        trunc(@lat);
        trunc(@qlen);
}
