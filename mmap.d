dtrace -n 'syscall::mmap:entry /execname == "firefox"/ { @[ustack()] = sum(arg1); }'
