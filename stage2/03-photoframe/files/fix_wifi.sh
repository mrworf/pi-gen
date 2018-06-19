#!/bin/bash
#
# Simple hack, when RPi has wifi issues, it seems the wpa_supplicant
# has hung or crashed. This manifests itself by the networking script
# being unable to restart
#
# By killing wpa_supplicant and then trying to restart network again,
# it should rectify this situation.
#

iwconfig wlan0 | grep 'ESSID:off/any' >/dev/null
if [ $? -eq 0 ]; then
	if ! /etc/init.d/networking restart ; then
		killall wpa_supplicant
		/etc/init.d/networking restart
	fi
fi
