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

# Prompts user to press Q (or q) to quit, anything else returns to console
pause() {
	read -r -p "Press Enter to view the console, else press Q..." input

	case "$input" in
		Q|q)
			exit 0
		;;
		*)
			$0
		;;
	esac
}

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
	echo "[D]rop a drive from an array"
	echo "[L]ist RAID devices"
	echo "[G]row/expand an array"
	echo "[M]odify RAID level"

	echo ""
	echo "[Q]uit"

	read -p "Enter your choice: " CHOICE

	case "$CHOICE" in
		M|m)
			./convert_raid.sh "${@}"
			pause
		;;
		G|g)
			./grow_raid.sh "${@}"
			pause
		;;
		D|d)
			./remove_drives_raid.sh "${@}"
			pause
		;;
		Q|q)
			clear
		;;

		L|l)
			./list_raid.sh
			pause
		;;

		A|a)
			./start_raid.sh "${@}"
			pause
		;;
		C|c)
			./create_raid.sh "${@}"
			pause
		;;
		S|s)
			./stop_raid.sh "${@}"
			pause
		;;
		R|r)
			./remove_raid.sh "${@}"
			pause
		;;
		*)
			CHOICE=""
		;;
	esac

	if [ "$CHOICE" != "" ]; then
		if [ $# -gt 0 ]; then
			unset -v '$[@]'
		fi
	fi
done
