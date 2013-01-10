#!/bin/bash

echo "[>>] Creating a RAID array from given disks."
echo "[>>] Script assumes nothing about devices, and will reformat each drive."
echo "[>>] Back up any data before using disks to create array."

# No arguments passed, tell user how to run this
if [ $# -eq 0 ]; then
	DEVS=()

	echo "[>>] To skip the prompt for entering devices, please provide them as an argument"

	while IFS=  read -r -p "[..] Enter device (and/or partition), leave empty to finish list: " tmp; do
		[[ $tmp ]] || break
		DEVS+=("$tmp")
	done
else
	# Gets all the arguments after $0 and stores it in array
	DEVS=("${@}")
fi

if [ ${#DEVS[@]} -eq 0 ]; then
	echo "[>>] No drives provided.  Exiting..."
	exit 1
fi

## BLOCK
# Not used, but showcases the classic spinner
sp="/-\|"
sc=0
spin() {
	printf "\b${sp:sc++:1}"
	((sc==${#sp})) && sc=0
}
endspin() {
	printf "\r%s\n" "$@"
}
## /BLOCK

echo "[>>] Running RAID configuration on the following devices: ${DEVS[@]}"

# Loop through each device the user gave
for dev in "${DEVS[@]}"; do
	echo "-- Device: $dev"
	echo -n "> Zeroing out disk via /dev/zero..."

	# I've found if the device is not zeroed out, RAID typically
	# will not build properly...or at all.

	dd if=/dev/zero of=$dev bs=4096 > /dev/null 2>&1
	echo "done."

	echo -n "> Cleaning superblock..."

	# Similar to zeroing out the boot sector, but this is for RAID info
	mdadm --zero-superblock $dev > /dev/null 2>&1

	echo "done."
	echo -n "> Erasing all partition data..."

	# Erasing boot sector information (precautionary, maybe can be deleted)
	dd if=/dev/zero of=$dev bs=4096 count=1 > /dev/null 2>&1

	echo "done."
	echo -n "> Clearing kernel cache..."

	# Kernel caches devices information on boot, clear it with this
	partprobe -s > /dev/null 2>&1

	echo "done."
	echo -n "> Formating drive to non-FS data type..."

	# Interesting line here.  These are the commands needed to:
	# 1. Completely erase the device's partition table
	# 2. Create a new primary partition (1rst partition)
	# 3. Change it's type to non-FS data (needed for RAID building)
	# 4. Write changes to physical disk
	(echo o; echo n; echo p; echo 1; echo ; echo ; echo; echo t; echo da; echo w) | fdisk $dev > /dev/null 2>&1

	echo "done."
done

# Get the RAID ID (/dev/md#)
read -p "[..] RAID ID (!NOT! level; this will be /dev/md#): " RAIDID

# The RAID level (TODO: error checking of device amount compared to requirement of level)

# - Get RAID levels supported
LEVELS=$(cat /proc/mdstat | grep "Personalities" | awk -F':' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//;s/[\[]*//g;s/[]]*//g;s/\s/, /g;s/raid//g')
read -p "[..] RAID Level ($LEVELS): " RAIDLEVEL

echo -n "[>>] Generating RAID..."
# Similar to the formatting line in the while loop, but instead we tell mdadm that we are to create the array
echo "yes
" | mdadm --create /dev/md$RAIDID --level=$RAIDLEVEL --metadata=1.2 --raid-devices=${#DEVS[@]} ${DEVS[@]} > /dev/null 2>&1
echo "done."

# Temp holder so while loop works initially
check="working"

# While $check is not empty...
while [ ! -z "$check" ]; do
	# Get the completion status (see mdadm --detail /dev/md# for details)
	check=$(mdadm --detail /dev/md$RAIDID | grep "Resync Status" | awk '{print $4}')

	# Show it in our own special progress bar-ish way
	# "\r" moves to beginning of line since there is no newline char ("\n")
	echo -ne "[..] Progress of RAID build: $check\r"

	sleep 1
done

echo -ne "[>>] Progress of RAID build: 100%"
echo -ne "\n"

# Generate a mdadm.conf line and import it into file
echo -n "[>>] Generating /etc/mdadm/mdadm.conf file..."
mdadm --examine --scan > /etc/mdadm/mdadm.conf
echo "done."

# Essentially tells mdadm to make the new RAID usable
echo -n "[>>] Assembling RAID for use..."
mdadm --assemble --scan > /dev/null 2>&1
echo "done."

echo "[>>] RAID array has been created at /dev/md$RAIDID at level $RAIDLEVEL"

echo -n "[>>] Creating partition for RAID..."
(echo o; echo n; echo p; echo 1; echo ; echo ; echo; echo t; echo 83; echo w) | fdisk /dev/md$RAIDID > /dev/null 2>&1
mkfs.ext4 /dev/md${RAIDID}p1 > /dev/null 2>&1
echo "done."

read -p "[..] Enter mount point for /dev/md${RAIDID}p1 (leave empty to not mount): " mount

if [ -n "$mount" ]; then
	echo "[>>] Mounting RAID array to $mount..."

	if [ ! -d "$mount" ]; then
		echo "[!!] $mount does not exist, creating..."
		mkdir -p "$mount"
	fi

	mount /dev/md${RAIDID}p1 "$mount" > /dev/null 2>&1
	echo "[>>] /dev/md${RAIDID}p1 has been mounted to $mount"
fi
