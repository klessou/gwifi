#!/usr/bin/perl -w
use strict;
use English;
if ($EUID == 0) {
	system ("cp Gwifi.pl /usr/bin/gwifi");
	if (-e '/etc/gwifi.conf') {
		system ("cp gwifi.conf.default /etc/")
	} else {
		system ("cp gwifi.conf.default /etc/gwifi.conf")
	}
} else {print 'Only root can use this installation script'} 
