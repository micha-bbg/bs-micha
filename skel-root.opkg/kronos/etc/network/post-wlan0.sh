#!/bin/sh

echo Stopping WLAN

/sbin/wpa_cli terminate
sleep 2
