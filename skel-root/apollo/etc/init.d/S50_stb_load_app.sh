#!/bin/sh

PATH=/var/bin:/bin:/var/sbin:/sbin

dt -t"Starting app..."

if [ -x /etc/profile ] ; then
	. /etc/profile
fi

if [ -x /bin/autorun.sh ] ; then
	/bin/autorun.sh &
fi
