#!/bin/sh
#set -x

PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin
KERNEL_VERSION=`uname -r`
echo "Using kernel $KERNEL_VERSION"
KRNL_PATH=/lib/modules/$KERNEL_VERSION

dmesg -n1

date -s "2014-10-10 00:00"

. /etc/init.d/functions

loadmod()
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
echo "Running loadmod now ......."

echo ""
loadmod ipv6
loadmod tun
DEVNET=/dev/net
mkdir -p $DEVNET
if [ ! -c $DEVNET/tun ]; then
	[ -e $DEVNET/tun ] && rm -f $DEVNET/tun
	echo "Creating device node ${DEVNET}/tun"
	mknod $DEVNET/tun c 10 200
	chmod 600 $DEVNET/tun
fi
echo ""

#loadmod lnxplatSAR		???
#loadmod lnxfssDrv		???
loadmod lnxpvrDrv
loadmod lnxdvbciDrv
#loadmod lnxIPfeDrv		???
loadmod framebuffer cnxtfb_standalone=1 cnxtfb_hdwidth=1280 cnxtfb_hdheight=720 cnxtfb_autoscale_sd=2

if [ -f /opt/.load_3ddrivers ] ; then
	echo ""
	loadmod pvrnxpdc
	loadmod pvrvssbc
fi

echo ""
loadmod frontpanel
create_node "cs_display"
ln -sf /dev/cs_display /dev/display

logoview --background --timeout=20 --logo=/var/share/icons/logo.jpg

echo ""
dt -t"Loading drivers..."

#loadmod typhoon		???
loadmod sharp780x
loadmod dvb_api
loadmod cifs

echo "Driver modules loaded, please start the app now..."
echo ""
