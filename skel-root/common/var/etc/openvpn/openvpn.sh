#!/bin/sh

DAEMON="OpenVPN"
openvpn=/sbin/openvpn
confdir=/var/etc/openvpn
piddir=/var/run/openvpn
test -d $piddir || mkdir -p $piddir

action="$1" ; shift
config="$1" ; shift

case $action in
	start)
		name=""
		for conf in $confdir/${config:-*}.conf ; do
			test -f "$conf" || continue
			name=$(basename "${conf%%.conf}")
			pidfile="$piddir/${name}.pid"

			echo -n "Starting $DAEMON [$name] "

			if [ -f "$pidfile" ]; then
			    killproc -p "$pidfile" -USR2 $openvpn
			    ret=$?
			    case $ret in
			      7) # not running, remove pid and start
				 echo -n "(removed stale pid file) "      ;
			         rm -f "$pidfile"                         ;;
			      0) # running - no an error, skip start
			         continue ;;
			      *) # another error, set it and continue
			         continue ;;
			    esac
			fi
			# openvpn may ask for auth ...
			echo ""

			$openvpn --daemon \
				--writepid "$pidfile" \
				--config "$conf" \
				--cd $confdir || \
			{
				if [ ! -w "$piddir" ]; then
					# this is one possible reason, but common to
					# all instances and better than nothing ...
					echo "  Can not write $pidfile"
#					exit 1
				fi
				echo "  See /var/log/messages for the failure reason"
				continue
			}
		done
		test -n "$name" || {
			echo "Starting $DAEMON${config:+ [$config]} -- not configured"
			exit 1
		}
		;;
	stop)
		name=""
		for pidfile in $piddir/${config:-*}.pid; do
			test -f "$pidfile" || continue
			name=$(basename "${pidfile%%.pid}")

			echo "Shutting down $DAEMON [$name] "
			killproc -p "$pidfile" $openvpn
			rm -f "$pidfile" > /dev/null 2>&1
		done
		test -n "$name" || {
			echo "Shutting down $DAEMON${config:+ [$config]} -- not running"
			exit 1
		}
		;;
	restart)
		$0 stop
		echo ""
		sleep 3
		$0 start
		;;
	status)
		echo ""
		openvpn --version
		name=""
		echo ""
		for pidfile in $piddir/${config:-*}.pid; do
			test -f "$pidfile" || continue
			name=$(basename "${pidfile%%.pid}")
			echo -n "Checking for $DAEMON [$name] - "
			killproc -p "$pidfile" -USR2 $openvpn
			if [ $? == 0 ]; then
				echo "running"
			else
				echo "not running"
			fi
		done
		exit 0
		;;
	version)
		echo "-----------"
		openvpn --version
		echo "-----------"
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status|version}"
		exit 1
		;;
esac

exit 0
