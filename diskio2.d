#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option destructive

/*
 * Disk cache flush (due to SYNC) is one of the costliest disk IO ops.
 * Here we log all those cache flush that lasts more than a threshold
 * to syslog.
 */

BEGIN
{
        ms = 1000000; /* 1 milli second = 1000000 nano seconds */
        thresh["ada0"] = 10 * ms; /* ssd cache flush less than 10 ms */
        thresh["da0"] = 200 * ms; /* hd cache flush less than 200 ms */
        thresh["da1"] = 200 * ms; /* hd cache flush less than 200 ms */
        thresh["da2"] = 200 * ms; /* hd cache flush less than 200 ms */
        thresh["da3"] = 200 * ms; /* hd cache flush less than 200 ms */
        thresh["da4"] = 200 * ms; /* hd cache flush less than 200 ms */
        thresh["da5"] = 200 * ms; /* hd cache flush less than 200 ms */
}

fbt::g_disk_start:entry
{
        this->bio = (struct bio *)arg0;
}

fbt::g_disk_start:entry
/this->bio->bio_cmd == 16/
{
        flush[stringof(this->bio->bio_to->name), 16] = timestamp;
}

fbt::g_disk_done:entry
/(this->bio = (struct bio *)arg0) && (this->bio->bio_cmd == 16)/
{
        this->name = stringof(this->bio->bio_disk->d_geom->name);
        this->delta = timestamp - flush[this->name, this->bio->bio_cmd];
        flush[stringof(this->name), this->bio->bio_cmd] = 0;
}

fbt::g_disk_done:entry
/this->delta > thresh[this->name]/
{
        system("logger -t CACHE_FLUSH %5s %d ms", this->name,
                this->delta / 1000000);
}
