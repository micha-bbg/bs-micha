#!/bin/sh

#################################################################
#                                                               #
#   camd_start.sh, v 3.15 17.01.2013 by FE-WORLD (FritzErwin)   #
#                                                               #
#################################################################

OSCAMXP=/var/bin/oscamXP

EchoExt()
{
	echo "[camd_start.sh] $1"
}

StopCam()
{
	# stop emus
	if [ ! "$1" = "quiet" ]; then
		EchoExt "stop camds"
	fi
	camd_service.sh oscam stop $1
	if [ -e $OSCAMXP ]; then
		camd_service.sh oscamXP stop $1
	fi
	TMPX=/tmp/_xxXxx_
	touch $TMPX > /dev/null 2>&1
	if [ -e $TMPX ]; then
		rm -rf /tmp/os* /tmp/.os*
		rm -f $TMPX
	fi
}

StartCam()
{
	# start emus
	if [ -e $OSCAMXP ]; then
		camd_service.sh oscamXP start $1
	fi
	camd_service.sh oscam start $1
}

case "$1" in
	start)
		StartCam
		;;
	stop)
		StopCam
		;;
	restart)
		StopCam
		sleep 1
		StartCam
		;;
	first_start)
		StopCam quiet
		sleep 1
		StartCam no_rezap
		;;
	start_from_neutrino)
		## Nix, nur ReZap von Neutrino aus (zur Zeit).

#		EchoExt "CamdStart from neutrino - rezap..."
#		pzapit -rz
		;;
	start1_from_camdThread)
		## Nix, nur ReZap von Neutrino aus (zur Zeit).

#		EchoExt "CamdStart start1_from_camdThread - rezap..."
#		pzapit -rz

#		EchoExt "CamdStart start1_from_camdThread - restart..."
#		StopCam
#		sleep 1
#		StartCam

		;;
	start2_from_camdThread)
		## Nix, nur ReZap von Neutrino aus (zur Zeit).

#		EchoExt "CamdStart start2_from_camdThread - rezap..."
#		pzapit -rz

#		EchoExt "CamdStart start2_from_camdThread - restart..."
#		StopCam
#		sleep 1
#		StartCam

		;;
esac

exit 0
