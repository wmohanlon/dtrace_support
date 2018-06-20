dtrace -n 'tcp:::accept-established { @[args[4]->tcp_dport] = count(); }'
