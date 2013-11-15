#!/bin/sh

case "$1" in
	start)
		if [ ! -e /var/etc/.samba_server ]; then
			echo "no samba start..."
			exit 0
		fi
		for i in smbd nmbd; do
			printf "starting ${i}..."
			if pidof $i > /dev/null; then
				echo " already running"
			else
				$i -D
				echo " done"
			fi
		done
		;;
	stop)
		for i in nmbd smbd; do
			printf "stopping ${i}..."
			if pidof $i > /dev/null; then
				read pid < /var/run/${i}.pid
				kill $pid && echo " done" || echo " failed!?"
			else
				echo " not running"
			fi
		done
		;;
	restart)
		$0 stop
		sleep 3
		$0 start
		;;
	status)
		for i in smbd nmbd; do
			printf "service ${i}..."
			if pidof $i > /dev/null; then
				echo " is running."
			else
				echo " is not running."
			fi
		done
		;;
	version)
		for i in smbd nmbd; do
			printf "${i} - "
			$i -V
		done
		;;
	*)
		echo "usage: $0 <start|stop|restart|status|version>"
		;;
esac
