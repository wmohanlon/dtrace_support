dtrace -n ::sonewconn:return'/args[1] == NULL/
{ 
print("sonewconn returned NULL"); 
printf("user stack %s (%d)", execname, pid);
ustack();
print("Kernel stack");
stack();
}'
