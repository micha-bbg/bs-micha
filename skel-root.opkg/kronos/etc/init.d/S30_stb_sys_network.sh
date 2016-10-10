#!/bin/sh

#set -x
PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin

dt -t"Starting network..."

# start network.
echo "Starting Network now..."

# start localhost
ifup -f lo

# start eth0
ifup -f eth0

# telnet
if [ -e /var/etc/.telnetd -a -x /sbin/telnetd ]; then
	echo "Starting telnetd"
	/sbin/telnetd -f /etc/issue
fi

exit 0

# UPNP
mkdir -p /media/00upnp
if [ -e /var/etc/.djmount -a -x /bin/djmount ]; then
	echo "Starting djmount"
	/bin/djmount -o iocharset=UTF-8 /media/00upnp &
fi

if [ -e /var/etc/.ushare -a -x /bin/ushare ]; then
	echo "Starting ushare"
	sleep 10
	/bin/ushare -D &
fi

# dropbear
if [ -e /var/etc/.dropbear -a -x /sbin/dropbear ]; then
	echo "Starting dropbear"
	# Check for the Dropbear RSA key
	if [ ! -f /etc/dropbear/dropbear_rsa_host_key ] ; then
		dt -t"Generating SSH rsa key ..."
		echo "generating rsa key... "
		dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key > /dev/null 2>&1
	fi

	# Check for the Dropbear DSS key
	if [ ! -f /etc/dropbear/dropbear_dss_host_key ] ; then
		dt -t"Generating SSH dsa key ..."
		echo "generating dsa key... "
		dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key > /dev/null 2>&1
	fi
	dropbear -B
fi
