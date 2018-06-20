dtrace -x ustackframes=100 -n 'vminfo:::as_fault /execname == "firefox"/ {
    @[ustack()] = count(); } tick-60s { exit(0); }' > out.firefox
