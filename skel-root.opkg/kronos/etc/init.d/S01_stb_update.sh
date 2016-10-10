#!/bin/sh

#mount -t proc proc /proc

#ETH0_LINK_STATUS=`ip link show eth0 up`
#if [ "x$ETH0_LINK_STATUS" != "x" ]; then
#exit
#fi

DO_REBOOT=0

if [ -f /var/update/vmlinux.ub.gz ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	echo Updating kernel on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/vmlinux.ub.gz > /dev/$DEV
	rm /var/update/vmlinux.ub.gz
	DO_REBOOT=1
fi

if [ -f /var/update/u-boot.bin ]; then
	DEV=`grep -i u-boot /proc/mtd | cut -f 0 -s -d :`
	echo Updating u-boot on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/u-boot.bin > /dev/$DEV
	rm /var/update/u-boot.bin

	VARDEV=`grep -i var /proc/mtd | cut -f 0 -s -d :`
	if [ -z $VARDEV ]; then
		ENVDEV=`grep -i env /proc/mtd | cut -f 0 -s -d :`
		echo no var partition found, erasing env in /dev/$ENVDEV ...
		/sbin/flash_eraseall /dev/$ENVDEV
	fi

	DO_REBOOT=1
fi

if [ -f /var/update/uldr.bin ]; then
	DEV=`grep -i uldr /proc/mtd | cut -f 0 -s -d :`
	echo Updating loader on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/uldr.bin > /dev/$DEV
	rm /var/update/uldr.bin
	DO_REBOOT=1
fi

if [ $DO_REBOOT == 1 ]; then
	echo Reboot...
	sync
	sleep 2
	/sbin/reboot -f
fi
