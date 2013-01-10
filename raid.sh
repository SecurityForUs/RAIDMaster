#!/bin/bash

# This is basically a wrapper or central console of sorts for
# this RAID management package.
#
# Any arguments passed to this script is handed off to the selected choice.
#
# It's kind of advisable to run this instead of the scripts manually,
# just because this script is nice and cool.
#
# Written by: Eric Hansen <ehansen@securityfor.us>
#

CHOICE=""

while [ "$CHOICE" == "" ]; do
	clear

	echo "RAID Master Central Console v1.0.0 (Non-licensed)"
	echo "----------------------------"
	echo "This was created to make RAID array management easier."
	echo "Each of the below options just runs another script."
	echo ""

	echo "[C]reate a new array"
	echo "[S]top an or all array"
	echo "[A]ctivate/start an array"
	echo "[R]emove an array from the system"

	read -p "Enter your choice: " CHOICE

	case "$CHOICE" in
		A|a)
			./start_raid.sh "${@}"
		;;
		C|c)
			./create_raid.sh "${@}"
		;;
		S|s)
			./stop_raid.sh "${@}"
		;;
		R|r)
			./remove_raid.sh "${@}"
		;;
		*)
			CHOICE=""
		;;
	esac
done
