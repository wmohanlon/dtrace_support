#!/usr/sbin/dtrace -s

    	::nlm_get_rpc:entry
    	{
    		/* this->hints = (struct sockaddr_in *)copyin(arg0, sizeof (struct sockaddr_in)); */
    		this->hints = (struct sockaddr_in *)arg0;
    		printf("family=%x addr=%d.%d.%d.%d",
    		    this->hints->sin_family,
    		    this->hints->sin_addr.s_addr & 0xFF,
    		    (this->hints->sin_addr.s_addr >> 8) & 0xFF,
    		    (this->hints->sin_addr.s_addr >> 16) & 0xFF,
    		    (this->hints->sin_addr.s_addr >> 24) & 0xFF);
    	}
