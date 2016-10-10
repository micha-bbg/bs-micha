#!/bin/sh
#set -x

PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin
KERNEL_VERSION=`uname -r`
echo "Using kernel $KERNEL_VERSION"
KRNL_PATH=/lib/modules/$KERNEL_VERSION

dmesg -n1

date -s "2016-10-01 00:00"

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
		/sbin/modprobe -q $modname $@
	fi
}

echo ""
echo "Running loadmod now ......."

#loadmod ipv6
loadmod tun
DEVNET=/dev/net
mkdir -p $DEVNET
if [ ! -c $DEVNET/tun ]; then
	[ -e $DEVNET/tun ] && rm -f $DEVNET/tun
	echo "Creating device node ${DEVNET}/tun"
	mknod $DEVNET/tun c 10 200
	chmod 600 $DEVNET/tun
fi

loadmod lnxpvrDrv
loadmod lnxdvbciDrv
loadmod framebuffer cnxtfb_standalone=1 cnxtfb_hdwidth=1280 cnxtfb_hdheight=720 cnxtfb_autoscale_sd=2

logoview --background --timeout=20 --logo=/var/share/icons/logo.jpg

loadmod frontpanel
create_node "cs_display"
ln -sf /dev/cs_display /dev/display

dt -t"Loading drivers..."

loadmod blazer
loadmod tavor
loadmod a8296
loadmod av201x
loadmod sharp780x
loadmod mxl603
loadmod dvb_api
loadmod cifs
loadmod fuse

echo "Driver modules loaded, please start the app now..."
echo ""
