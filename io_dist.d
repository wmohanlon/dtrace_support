#!/usr/sbin/dtrace -qs

     

io:::start
{
        start[args[0]->bio_dev, args[0]->bio_offset] = timestamp;
}

io:::done
/start[args[0]->bio_dev, args[0]->bio_offset]/
{
        this->elapsed = timestamp - start[args[0]->bio_dev, args[0]->bio_offset];
        @[args[1]->device_name, args[1]->unit_number] =
            quantize(this->elapsed);
        start[args[0]->bio_dev, args[0]->bio_offset] = 0;
}

END
{
        printf("Disk Service Time Histograms\n\n");
        printa("  %s (%d) \n%@d\n", @);
        printf("%s ended %Y\n", $0, walltimestamp);
}
