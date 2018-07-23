#!/bin/bash
#
# Simple hack, when RPi has wifi issues, it seems the wpa_supplicant
# has hung or crashed. This manifests itself by the networking script
# being unable to restart
#
# By killing wpa_supplicant and then trying to restart network again,
# it should rectify this situation.
#
# Now also continously monitors wifi and triggers restarts to make sure
# frame stays connected to wifi.

while true ; do
	if iwconfig wlan0 | grep 'ESSID:off/any' ; then
		if ! /etc/init.d/networking restart ; then
			killall wpa_supplicant
			sleep 2s # Make sure it's gone
			/etc/init.d/networking restart
		fi
		sleep 30s # Give it extra time...
	fi
	sleep 30s
done

