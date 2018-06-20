#!/usr/sbin/dtrace -s
  *::*g_eli*:entry
  {
     @num[probefunc] = count() ;
  }

/*
  tick-10sec
  {
     exit(0);
  }
*/
