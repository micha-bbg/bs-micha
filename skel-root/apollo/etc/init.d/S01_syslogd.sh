#!/bin/sh

# Start syslogd early so we have logger messages in syslog.
if [ -e /sbin/syslogd ]; then
	/sbin/syslogd -m 0
fi
