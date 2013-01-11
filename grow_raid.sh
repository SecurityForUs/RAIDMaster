#!/bin/bash

echo "[>>] Add devices to a RAID array to make it grow"

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
	echo "     $0 <RAID device to grow> <space-separated list of devices>"

	# No args passed, we need RAID device
	if [ $# -eq 0 ]; then
		# While no device is provided, ask user for one
		while [ "$RAID" == "" ]; do
			read -r -p "[..] Enter RAID device you want to grow: " RAID
		done
	else
		# We at least have a RAID device passed
		RAID="$1"
	fi

	while IFS=  read -r -p "[..] Enter device to add to $RAID, leave empty to finish list: " tmp; do
		[[ $tmp ]] || break
		DEVS+=("$tmp")
	done
else
	RAID="$1"
	shift
	DEVS=("${@}")
fi

echo "[>>] RAID device: $RAID"
echo "[>>] Drives to use: ${DEVS[@]}"

read -r -p "[..] Are you sure (Y/n)? " CHOICE

case "$CHOICE" in
	N|n)
		echo "Exiting program..."
		exit 1
	;;
esac

echo "[>>] Performing operations on drives..."

for dev in "${DEVS[@]}"; do
	echo "[--] Operating on $dev"

	echo -n "[  ] Zeroing disk..."
	dd if=/dev/zero of=$dev bs=4096 > /dev/null 2>&1
	echo "done."

	echo -n "[  ] Cleaning superblock..."
	mdadm --zero-superblock $dev > /dev/null 2>&1
	echo "done."

	echo -n "[  ] Erasing partition data..."
	dd if=/dev/zero of=$dev bs=4096 count=1 > /dev/null 2>&1
	echo "done."

	echo -n "[  ] Clearning kernel cache..."
	partprobe -s > /dev/null 2>&1
	echo "done."

	echo -n "[  ] Reformatting to non-FS data type..."
	(echo o; echo n; echo p; echo 1; echo ; echo ; echo ; echo t; echo da; echo w) | fdisk $dev > /dev/null 2>&1
	echo "done."
done

DC=$(mdadm --detail $RAID | grep "Total Devices" | awk -F':' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')

echo -n "[>>] Adding devices to array..."
mdadm --add $RAID ${DEVS[@]} > /dev/null 2&>1
echo "done."

COUNT=${#DEVS[@]}

NEW_DEVS=$(echo -n "$DC" | awk -v count=$COUNT '{print $1+count}')

echo -n "[>>] Expanding RAID disk allocation on $RAID from $DC disks to $NEW_DEVS..."
mdadm --grow --force -n $NEW_DEVS $RAID > /dev/null 2>&1
echo "done."

CHECK="y"

while [ -n "$CHECK" ]; do
	CHECK=$(mdadm --detail $RAID | grep "Rebuild Status" | awk '{print $4}')
	echo -ne "[>>] Progress of build: $CHECK\r"
	sleep 1
done

echo -ne "[>>] Progres of build: 100%\n"
