tcp:::accept-established {
 @[args[4]->tcp_dport] = count();
}

tick-1sec
{
 printa(@);
}
