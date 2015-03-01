#!/bin/sh

echo Starting WLAN

mkdir /var/run/wpa_supplicant
/sbin/wpa_cli terminate
sleep 1

#/sbin/wpa_supplicant -B -D wext -i ra0 -c /etc/wpa_supplicant.conf //ralink
/sbin/wpa_supplicant -D wext -c /etc/wpa_supplicant.conf -i wlan0 -B
sleep 8
