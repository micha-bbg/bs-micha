#!/bin/sh

PATH=/var/bin:/bin:/var/sbin:/sbin

# Generate a hostname if none set
if [ ! -f /etc/hostname ]; then
	echo `ifconfig eth0 | awk '/HWaddr/ { split($5,v,":"); print "CST-"  v[4] v[5] v[6] }'` > /etc/hostname
fi

# Set hostname in the system
/bin/hostname -F /etc/hostname
