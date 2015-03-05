#!/bin/sh

RULES_DIR=/var/etc/iptables

PORT_UDP_FILE=${RULES_DIR}/udp_ports
PORT_TCP_FILE=${RULES_DIR}/tcp_ports
SERVICES_UDP=""
SERVICES_TCP=""
if [ -e $PORT_UDP_FILE ]; then
	SERVICES_UDP="$(cat $PORT_UDP_FILE)"
fi
if [ -e $PORT_TCP_FILE ]; then
	SERVICES_TCP="$(cat $PORT_TCP_FILE)"
fi

IP4T=iptables
IP6T=ip6tables
#IP4T="iptables -v"
#IP6T="ip6tables -v"

setRules_1()
{ 
	if [ "$1" = "4" ]; then
		CMD=$IP4T
	else
		CMD=$IP6T
	fi
	# remove all rules
	$CMD -F
	$CMD -t nat -F
	$CMD -t mangle -F
	$CMD -X
	$CMD -t nat -X
	$CMD -t mangle -X

	# default
	$CMD -P OUTPUT  ACCEPT
	$CMD -P INPUT   DROP
	$CMD -P FORWARD DROP

	# security
	$CMD -N other_packets
	$CMD -A other_packets -p ALL -m state --state INVALID -j DROP
	if [ "$1" = "4" ]; then
		$CMD -A other_packets -p icmp -j ACCEPT
	else
		$CMD -A other_packets -p icmpv6 -j ACCEPT
	fi
	$CMD -A other_packets -p ALL -j RETURN

	$CMD -N reject_packets
	$CMD -A reject_packets -p tcp -j REJECT --reject-with tcp-reset
	if [ "$1" = "4" ]; then
		$CMD -A reject_packets -p udp -j REJECT --reject-with icmp-port-unreachable
		$CMD -A reject_packets -p icmp -j REJECT --reject-with icmp-host-unreachable
		$CMD -A reject_packets -j REJECT --reject-with icmp-proto-unreachable
	else
		$CMD -A reject_packets -p udp -j REJECT --reject-with icmp6-port-unreachable
		$CMD -A reject_packets -p icmpv6 -j REJECT --reject-with icmp6-addr-unreachable
		$CMD -A reject_packets -j REJECT --reject-with icmp6-addr-unreachable
	fi
	$CMD -A reject_packets -p ALL -j RETURN

	# services
	$CMD -N services
	for port in $SERVICES_TCP ; do
		$CMD -A services -p tcp --dport $port -j ACCEPT
	done
	for port in $SERVICES_UDP ; do
		$CMD -A services -p udp --dport $port -j ACCEPT
	done
	$CMD -A services -p ALL -j RETURN

	# OUTPUT:
	$CMD -A OUTPUT -p ALL -j ACCEPT

	# INPUT
	$CMD -A INPUT -p ALL -i lo -j ACCEPT
	$CMD -A INPUT -p ALL -m state --state ESTABLISHED,RELATED -j ACCEPT
	$CMD -A INPUT -p ALL -j other_packets
	$CMD -A INPUT -p ALL -j services
}

setRules_2()
{ 
	if [ "$1" = "4" ]; then
		CMD=$IP4T
	else
		CMD=$IP6T
	fi
	$CMD -A INPUT -p ALL -j reject_packets
	$CMD -A INPUT -p ALL -j DROP

#	$CMD  -N logging
#	$CMD  -A INPUT -j logging
#	if [ "$1" = "4" ]; then
#		$CMD  -A logging -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
#	else
#		$CMD  -A logging -m limit --limit 2/min -j LOG --log-prefix "IP6Tables-Dropped: " --log-level 4
#	fi
#	$CMD  -A logging -j DROP
}

echo "[iptables] set IPV4 rules"
setRules_1 4
$IP4T -A INPUT -s 10.0.0.0/8 -j ACCEPT
$IP4T -A INPUT -s 172.16.0.0/12 -j ACCEPT
$IP4T -A INPUT -s 192.168.0.0/16 -j ACCEPT
setRules_2 4

## save IPV4 rules
iptables-save  > ${RULES_DIR}/iptables.rules

#modprobe ipv6 > /dev/null 2>&1
ip6tables -S INPUT 1 > /dev/null 2>&1
if [ "$?" = "0" ]; then
	echo "[iptables] set IPV6 rules"
	setRules_1 6
	$IP6T -A INPUT -s fe80::/10 -j ACCEPT
	$IP6T -A INPUT -d ff00::/8 -j ACCEPT
	setRules_2 6

	## save IPV6 rules
	ip6tables-save > ${RULES_DIR}/ip6tables.rules
fi

#/var/bin/fwmin.sh
## iptables -nvL
## ip6tables -nvL
