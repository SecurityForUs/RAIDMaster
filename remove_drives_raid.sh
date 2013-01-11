#!/bin/bash

echo "[>>] Remove devices from a RAID array"

# Start with an empty list
RAID=""
DEVS=()

# We should have two arguments:
# 1 - RAID device to grow
# 2...n - Devices to add to RAID
#
# However, if < 2 arguments, see how much we need to ask for
if [ $# -lt 2 ]; then
	echo "[>>] Not enough information provided, asking for what is needed..."
	echo "[>>] To prevent this, run:"
	echo "     $0 <RAID device to remove from> <space-separated list of devices>"

	# No args passed, we need RAID device
	if [ $# -eq 0 ]; then
		# While no device is provided, ask user for one
		while [ "$RAID" == "" ]; do
			read -r -p "[..] Enter RAID device you want to remove from: " RAID
		done
	else
		# We at least have a RAID device passed
		RAID="$1"
	fi

	while IFS=  read -r -p "[..] Enter device to remove from $RAID, leave empty to finish list: " tmp; do
		[[ $tmp ]] || break
		DEVS+=("$tmp")
	done
else
	RAID="$1"
	shift
	DEVS=("${@}")
fi

echo "[>>] RAID device: $RAID"
echo "[>>] Drives to remove: ${DEVS[@]}"

read -r -p "[..] Are you sure (Y/n)? " CHOICE

case "$CHOICE" in
	N|n)
		echo "Exiting program..."
		exit 1
	;;
esac

echo "[>>] Performing operations on RAID..."

for dev in "${DEVS[@]}"; do
	echo "[--] Operating on $dev"

	mdadm $RAID --fail $dev --remove $dev > /dev/null 2>&1
done

echo "[>>] New drive information for $RAID:"
mdadm --detail $RAID | grep "/dev/s"

COUNT=${#DEVS[@]}
DC=$(mdadm --detail $RAID | grep "Total Devices" | awk -F':' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
NEW_DEVS=$(echo -n "$DC" | awk -v count=$COUNT '{print $1+count}')

echo -n "[>>] Reducing RAID disk allocation on $RAID from $NEW_DEVS to $DC..."
mdadm --grow -n $DC $RAID > /dev/null 2>&1
echo "done."
