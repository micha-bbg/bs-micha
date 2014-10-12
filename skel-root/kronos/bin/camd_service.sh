#!/bin/sh

#################################################################
#                                                               #
#  camd_service.sh, v 3.12 21.12.2012 by FE-WORLD (FritzErwin)  #
#                                                               #
#################################################################

EchoExt()
{
	echo "[camd_service.sh] $1"
}

if [ "$1" = "" ]; then
	exit 1
fi
if [ "$2" = "" ]; then
	exit 1
fi

CAMD=$1
ACTION=$2
case "$CAMD" in
	oscam)
		PARAM="-b -c /var/keys -w 0"
		;;
	oscamXP)
		PARAM="-b -c /var/keys/2th -w 0"
		;;
	*)
		exit 1
		;;
esac

KillCamd()
{
	i=0
	if [ "$2" = "quiet" ]; then
		QUIET=1
	else
		QUIET=0
	fi
	CAMPID="$(pidof $1)"
	while [ "$CAMPID" ]; do
		if [ $i -lt 5 ]; then
			if [ "$QUIET" = "0" ]; then
				EchoExt "kill $1 (PID $CAMPID)"
			fi
			kill $CAMPID
		else
			if [ "$QUIET" = "0" ]; then
				EchoExt "killall -9 $1"
			fi
			killall -9 $1
		fi
		sleep 1
		CAMPID="$(pidof $1)"
		i=$(expr $i + 1)
		if [ $i -ge 10 ]; then
			if [ "$QUIET" = "0" ]; then
				EchoExt "kill $1 break..."
			fi
			break
		fi
	done
}

ReZap()
{
	if [ "$1" = "no_rezap" ]; then
		return
	fi
	EchoExt "rezap"
	pzapit -rz
}

case "$ACTION" in
	start)
		EchoExt "start $CAMD $PARAM"
		$CAMD $PARAM > /dev/null 2>&1
		if [ "$CAMD" = "oscam" ]; then
			sleep 1
			ReZap $3
		fi
		;;
	stop)
		KillCamd $CAMD $1
		;;
	restart)
		$0 $CAMD stop
		sleep 1
		$0 $CAMD start
		;;
	*)
		exit 1
		;;
esac
