#!/bin/bash

echo "[>>] Convert RAID array from one level to another"

# Start with an empty list
RAID=""
LEVEL=""

# We should have two arguments:
# 1 - RAID device to grow
# 2...n - Devices to add to RAID
#
# However, if < 2 arguments, see how much we need to ask for
if [ $# -lt 2 ]; then
	echo "[>>] Not enough information provided, asking for what is needed..."
	echo "[>>] To prevent this, run:"
	echo "     $0 <RAID device to change> <new level>"

	# No args passed, we need RAID device
	if [ $# -eq 0 ]; then
		# While no device is provided, ask user for one
		while [ "$RAID" == "" ]; do
			read -r -p "[..] Enter RAID device you want to change: " RAID
		done
	else
		# We at least have a RAID device passed
		RAID="$1"
	fi

	while [ "$LEVEL" == "" ]; do
		read -r -p "[..] Enter new level for $RAID: " LEVEL
	done
else
	RAID="$1"
	LEVEL="$2"
fi

OLD_LEVEL=$(mdadm --detail $RAID | grep "Raid Level" | awk -F':' '{print $2}' | sed 's/raid//;s/^[ \t]*//')

echo "[>>] RAID device: $RAID"
echo "[>>] Old level: $OLD_LEVEL"
echo "[>>] New level: $LEVEL"

read -r -p "[..] Are you sure (Y/n)? " CHOICE

case "$CHOICE" in
	N|n)
		echo "Exiting program..."
		exit 1
	;;
esac

echo "[>>] Performing operations on RAID..."

mdadm --grow $RAID --level $LEVEL
# > /dev/null 2>&1

echo "[>>] New drive information for $RAID:"
mdadm --detail $RAID
