dtrace -n 'fbt::fop_read:entry { self->start = timestamp; }
    fbt::fop_read:return /self->start/ { @[execname, "ns"] =
    quantize(timestamp - self->start); self->start = 0; }'
