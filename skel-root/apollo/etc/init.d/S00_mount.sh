#!/bin/sh

PATH=/var/bin:/bin:/var/sbin:/sbin

mount -t proc proc /proc

# Create console and null devices if they don't exist.
[ -e /dev/console ] || mknod -m 644 /dev/console c 5 1
[ -e /dev/null ] || mknod -m 666 /dev/null  c 1 3

mount -t tmpfs tmpfs /tmp
mount -t sysfs sys /sys
mount -t tmpfs tmp /tmp
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
mkdir -p /dev/shm/usb
mount -t usbfs none /proc/bus/usb
mkdir -p /tmp/dev
#mount -a

# the ethernet chip needs 2 seconds to initialize...
# ...so start it *now*, then real network setup is fast
echo ifconfig eth0 up
ifconfig eth0 up

