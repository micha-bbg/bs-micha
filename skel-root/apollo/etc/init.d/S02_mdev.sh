#!/bin/sh

PATH=/var/bin:/bin:/var/sbin:/sbin

echo /sbin/mdev > /proc/sys/kernel/hotplug
echo > /dev/mdev.seq

mdev -s
