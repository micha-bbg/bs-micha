#!/bin/sh

PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin

echo /sbin/mdev > /proc/sys/kernel/hotplug
echo > /dev/mdev.seq

mdev -s
