#!/bin/sh

DO_REBOOT=0

if [ -f /var/update/uldr.bin ]; then
	DEV=`grep -i uldr /proc/mtd | cut -f 0 -s -d :`
	echo update loader on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/uldr.bin > /dev/$DEV
	rm /var/update/uldr.bin
	DO_REBOOT=1
fi

if [ -f /var/update/u-boot.bin ]; then
	DEV=`grep -i u-boot /proc/mtd | cut -f 0 -s -d :`
	echo update u-boot on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/u-boot.bin > /dev/$DEV
	rm /var/update/u-boot.bin
	DO_REBOOT=1
fi

if [ -f /var/update/vmlinux.ub.gz ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	echo update kernel on device $DEV .....
	/sbin/flash_eraseall /dev/$DEV && /bin/cat /var/update/vmlinux.ub.gz > /dev/$DEV
	rm /var/update/vmlinux.ub.gz
	DO_REBOOT=1
fi

if [ $DO_REBOOT == 1 ]; then
	echo reboot....
	sync
	/sbin/reboot -f
fi
