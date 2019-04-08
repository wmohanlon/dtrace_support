fbt:zfs:zvol_strategy:entry
/args[0]->bio_cmd == 1/
{
    zv = (zvol_state_t*)(args[0]->bio_to->private);
    @reads[stringof(zv->zv_name), "read"] = count();
}
fbt:zfs:zvol_strategy:entry
/args[0]->bio_cmd == 2/
{
    zv = (zvol_state_t*)(args[0]->bio_to->private);
    @writes[stringof(zv->zv_name), "write"] = count();
}

