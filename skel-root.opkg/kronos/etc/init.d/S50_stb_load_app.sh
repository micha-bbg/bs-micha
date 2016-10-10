#!/bin/sh

PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin

dt -t"Starting app..."

test -e /etc/ld.so.cache || ldconfig

if [ -x /etc/profile ] ; then
	. /etc/profile
fi

if [ -x /bin/autorun.sh ] ; then
	/bin/autorun.sh &
fi
