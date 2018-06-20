tcp:::accept-refused {
 @[args[4]->tcp_dport] = count();
}
tcp:::connect-refused {
 @[args[4]->tcp_dport] = count();
}

tick-1sec
{
 printa(@);
}
