dtrace:::BEGIN
{
printf("Tracing hit ctrl-c to end\n");
}

syscall:freebsd:socket:return
{
	printf("%s %d", execname, args[1]);
}

dtrace:::END
{
}

