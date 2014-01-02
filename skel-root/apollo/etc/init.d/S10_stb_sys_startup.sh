#!/bin/sh
#set -x

PATH=/var/bin:/bin:/var/sbin:/sbin

KRNL_VER=$(uname -r)
echo "Using kernel $KRNL_VER"
KRNL_PATH=/lib/modules/$KRNL_VER

dmesg -n1

. /etc/init.d/functions

im()
{
	[ "$1" = "" ] && return;
	modname=$1
	shift
	file=$KRNL_PATH/${modname}.ko
	if test -e $file; then
		echo "insmod ${modname}.ko $@"
		/sbin/insmod $file $@
	else
		echo "modprobe $modname $@"
		/sbin/modprobe $modname $@
	fi
}

echo ""
#im kernel/drivers/net/tun
#im lnxplatnativeDrv
#im lnxKKALDrv
#im lnxnotifyqDrv
#im lnxplatDrv
#im lnxscsDrv
#im lnxcssDrv
#im lnxtmasDrv
#im lnxtmvssDrvGPL
#im lnxtmvssDrv
im lnxpvrDrv
im lnxdvbciDrv
im lnxdebugDrv
im framebuffer cnxtfb_standalone=1 cnxtfb_hdwidth=1280 cnxtfb_hdheight=720 cnxtfb_autoscale_sd=2

if [ -f /opt/.load_3ddrivers ] ; then
	echo ""
	im extra/pvrsrvkm
	im extra/pvrnxpdc
	im extra/pvrvssbc
fi

echo ""
#im control
im frontpanel
create_node "cs_display"
ln -sf /dev/cs_display /dev/display
dt -t"Loading drivers..."

logoview --background --timeout=20 --logo=/var/share/icons/logo-bbg.jpg

echo ""

#im dvb-core
#im typhoon
#im a8296
#im av201x
#im sharp780x
#im avl6211
#im dvb_api_prop
im dvb_api
im cifs

if [ -e /var/etc/.load_wlan_drivers ] ; then
	echo ""
	im cfg80211
	im lib80211
	im 8192cu
	im 8712u
	im rt2870sta
	im rt2500usb
	im rt2800usb
	im rt73usb
fi

echo ""
