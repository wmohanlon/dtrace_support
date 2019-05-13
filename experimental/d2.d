#!/usr/sbin/dtrace
	#pragma D option quiet
	profile:::profile-1000hz
	/pid == 28796/ 
	{
		@pc[arg1] = count();
	}
	dtrace:::END
	{
		printa("OUT: %d\n", @pc);
	}
