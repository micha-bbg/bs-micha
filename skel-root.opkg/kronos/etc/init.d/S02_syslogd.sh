#!/bin/sh

exit

# Start syslogd early so we have logger messages in syslog.
if [ -e /sbin/syslogd ]; then
	/sbin/syslogd -m 0
#	/sbin/syslogd -f /etc/syslog.conf
fi
