#!/bin/sh

RULES_DIR=/var/etc/iptables

IP4_OK=
IP6_OK=
iptables -S INPUT 1 > /dev/null 2>&1
[ "$?" = "0" ] && IP4_OK=1
ip6tables -S INPUT 1 > /dev/null 2>&1
[ "$?" = "0" ] && IP6_OK=1
if [ ! "$IP4_OK" = "1" -a ! "$IP6_OK" = "1" ]; then
	echo "[iptables] Firewall will not start, no iptables support..."
	exit
fi

echo "[iptables] Starting firewall..."

if [ "$IP4_OK" = "1" ]; then
	echo "[iptables] Import rules for ipv4"
	cat ${RULES_DIR}/iptables.rules | iptables-restore
fi

if [ "$IP6_OK" = "1" ]; then
	echo "[iptables] Import rules for ipv6"
	cat ${RULES_DIR}/ip6tables.rules | ip6tables-restore
fi
