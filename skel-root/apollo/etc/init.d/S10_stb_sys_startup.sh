#!/bin/sh
#set -x

PATH=/var/bin:/bin:/var/sbin:/sbin

KRNL_VER=$(uname -r)
echo "Using kernel $KRNL_VER"
KRNL_PATH=/lib/modules/$KRNL_VER

dmesg -n1

. /etc/init.d/functions

im() {
	[ "$1" = "" ] && return;
	if [ -f $KRNL_PATH/$1 ]; then
		echo "insmod $*"
		insmod $KRNL_PATH/$*
	else
		echo ">>>>> Error: modul $KRNL_PATH/$* not found."
	fi
}

mp()
{
	echo "modprobe $*"
	modprobe -v $*
}

echo ""
#im kernel/drivers/net/tun
mp lnxplatnativeDrv
mp lnxKKALDrv
mp lnxnotifyqDrv
mp lnxplatDrv
mp lnxdebugDrv
mp lnxscsDrv
mp lnxcssDrv
mp lnxtmasDrv
mp lnxtmvssDrvGPL
mp lnxtmvssDrv
mp lnxpvrDrv
mp lnxdvbciDrv
mp framebuffer cnxtfb_standalone=1 cnxtfb_hdwidth=1280 cnxtfb_hdheight=720 cnxtfb_autoscale_sd=2

if [ -f /opt/.load_3ddrivers ] ; then
	echo ""
	mp pvrsrvkm
	mp pvrnxpdc
	mp pvrvssbc
fi

echo ""
mp control
mp frontpanel
create_node "cs_display"
ln -sf /dev/cs_display /dev/display
dt -t"Loading drivers..."

logoview --background --timeout=20 --logo=/var/share/icons/logo-bbg.jpg

echo ""

mp dvb-core
mp typhoon
mp a8296
mp av201x
mp sharp780x
mp avl6211
mp dvb_api_prop
mp dvb_api
mp cifs

if [ -e /var/etc/.load_wlan_drivers ] ; then
	echo ""
	mp cfg80211
	mp lib80211
	mp 8192cu
	mp 8712u
	mp rt2870sta
	mp rt2500usb
	mp rt2800usb
	mp rt73usb
fi

echo ""
