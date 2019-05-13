#pragma D option quiet

BEGIN
{
        bio_cmd[0] = "0";
        bio_cmd[1] = "Read";
        bio_cmd[2] = "Write";
        bio_cmd[3] = "Delete";
        bio_cmd[4] = "Getattr";
        bio_cmd[5] = "Flush";
}


io:::start
/args[1] != 0 && args[0] != 0/
{
        @[args[1]->device_name, execname, bio_cmd[args[0]->bio_cmd], pid] = sum(args[0]->bio_bcount);
}

tick-5s
{
        printf("%10s %20s %10s %10s %15s\n", "DEVICE", "APP", "BIO_CMD", "PID", "BYTES");
        printa("%10s %20s %10s %10d %15@d\n", @);
	trunc(@);
}
