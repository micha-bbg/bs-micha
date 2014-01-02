#!/bin/sh
#set -x

PATH=/var/bin:/bin:/var/sbin:/sbin

KRNL_VER=$(uname -r)
echo "Using kernel $KRNL_VER"
if [ "$KRNL_VER" = "2.6.34" ]; then
	OLD_KRNL=1
else
	OLD_KRNL=0
fi
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

echo ""
#im kernel/drivers/net/tun.ko
im extra/lnxplatnativeDrv.ko
im extra/lnxKKALDrv.ko
im extra/lnxnotifyqDrv.ko
im extra/lnxplatDrv.ko
[ "$OLD_KRNL" = "0" ] && im extra/lnxdebugDrv.ko
[ "$OLD_KRNL" = "1" ] && im extra/lnxplatSAR.ko
im extra/lnxscsDrv.ko
[ "$OLD_KRNL" = "1" ] && im extra/lnxfssDrv.ko
im extra/lnxcssDrv.ko
im extra/lnxtmasDrv.ko
im extra/lnxtmvssDrvGPL.ko
im extra/lnxtmvssDrv.ko
im extra/lnxpvrDrv.ko
im extra/lnxdvbciDrv.ko
[ "$OLD_KRNL" = "1" ] && im extra/lnxIPfeDrv.ko
im extra/framebuffer.ko cnxtfb_standalone=1 cnxtfb_hdwidth=1280 cnxtfb_hdheight=720 cnxtfb_autoscale_sd=2

if [ -f /opt/.load_3ddrivers ] ; then
	echo ""
	im extra/pvrsrvkm.ko
	im extra/pvrnxpdc.ko
	im extra/pvrvssbc.ko
fi

echo ""
im extra/control.ko
im extra/frontpanel.ko
create_node "cs_display"
ln -sf /dev/cs_display /dev/display
dt -t"Loading drivers..."

logoview --background --timeout=20 --logo=/var/share/icons/logo-bbg.jpg

echo ""

if [ "$OLD_KRNL" = "1" ]; then
	im dvb/dvb-core.ko
else
	im kernel/drivers/media/dvb/dvb-core/dvb-core.ko
fi
im extra/typhoon.ko
im extra/a8296.ko
im extra/av201x.ko
im extra/sharp780x.ko
im extra/avl6211.ko
im extra/dvb_api_prop.ko
im extra/dvb_api.ko
if [ "$OLD_KRNL" = "1" ]; then
	im fs/cifs/cifs.ko
else
	im kernel/fs/cifs/cifs.ko
fi

if [ -e /var/etc/.load_wlan_drivers ] ; then
	echo ""
	if [ "$OLD_KRNL" = "1"]; then
		im net/wireless/cfg80211.ko
		im net/wireless/lib80211.ko
		im net/wireless/8192cu/8192cu.ko
		im net/wireless/8712u/8712u.ko
	else
		im kernel/net/wireless/cfg80211.ko
		im kernel/net/wireless/lib80211.ko
		im extra/8192cu.ko
		im extra/8712u.ko
	fi
#	im net/wireless/rt2870/rt2870sta.ko
#	im net/wireless/rt2x00/rt2500usb.ko
#	im net/wireless/rt2x00/rt2800lib.ko
#	im net/wireless/rt2x00/rt2800usb.ko
#	im net/wireless/rt2x00/rt2x00lib.ko
#	im net/wireless/rt2x00/rt2x00usb.ko
#	im net/wireless/rt2x00/rt73usb.ko
fi

echo ""
