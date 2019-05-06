#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=2997hz
#pragma D option dynvarsize=8m

/*
 * This script trace disk io from g_disk_start to g_disk_done.
 * Both functions have only one argument of type struct bio *.
 * But since we only enter g_disk_done after the disk finish
 * reading the data and generate an interrupr, there is no
 * guarantee that the two bio's are the same. After a lot of
 * experiments, I end up with the following identifiers.
 * Also, note that while this->bio->bio_to->name and
 * this->bio->bio_disk->d_geom->name may refer to the same
 * da2, they are only equal when we take stringof them.
 * The high switchrate of this scripts is due to the high
 * collisions of the array with our current keys.
 * See <sys/bio.h>, <geom/geom.h> and <geom/geom_disk.h>.
 */

BEGIN
{
        bio_cmd[0] = "0";
        bio_cmd[1] = "Read";
        bio_cmd[2] = "Write";
        bio_cmd[3] = "Delete";
        bio_cmd[4] = "Getattr";
        bio_cmd[5] = "Flush";
}

fbt::g_disk_start:entry
/args[0]->bio_cmd == 2/
{
        this->bio = (struct bio *)arg0;
}

fbt::g_disk_start:entry
/args[0]->bio_cmd == 2/
{
        this->s_name = stringof(this->bio->bio_to->name);
        ddn[this->bio->bio_data, this->s_name, this->bio->bio_cmd] = timestamp;
        @start = count();
}

fbt::g_disk_done:entry
/(this->bio = (struct bio *)arg0) &&
(this->name = this->bio->bio_disk->d_geom->name) &&
(this->ts = ddn[this->bio->bio_data, stringof(this->name), this->bio->bio_cmd]) &&
(args[0]->bio_cmd == 2)/
{
        this->op = bio_cmd[this->bio->bio_cmd];
        @lat[stringof(this->name), this->op] = quantize((timestamp - this->ts)/(1000*1000));
        @iosize[stringof(this->name), this->op] = quantize(this->bio->bio_bcount);
        ddn[this->bio->bio_data, stringof(this->name), this->bio->bio_cmd] = 0;
        @end = count();
}

tick-5s 
/* tick-1s */
{
        printf("Latencies (ms)\n\n");
        printa("%s %s %@d\n", @lat);
        /*printf("IO sizes (bytes)\n\n");
        printa("%s %s %@d\n", @iosize);
        printf("Booking keeping\n");
        printa(@start, @end);*/
        printf("------------------------------------------------\n\n");
        trunc(@lat);
        trunc(@iosize);
        trunc(@start);
        trunc(@end);
}
