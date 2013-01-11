#!/bin/bash

# Get the RAID device to remove
if [ $# -eq 0 ]; then
	read -r -p "Enter device to remove: " RAID
else
	RAID=$1
fi

# Checks to see if the device is present
DETECT=$(fdisk -l $RAID | grep -v "partition table")

if [ -z "$DETECT" ]; then
	echo "$RAID is not detected as a device."
	exit 1
fi

echo "> RAID to delete: $RAID"

# We have to unmount the RAID device in order to remove it
echo -n "Unmounting RAID to perform operations..."
umount $RAID > /dev/null 2&>1
echo "done."

# If we don't stop the RAID device we will not be able to remove drives
echo  -n "Stopping RAID so we can delete it..."
mdadm -S $RAID > /dev/null 2&>1
echo "done."

# Simply done to remove devices from the array
echo -n "Zero-blocking each device after removing it from the array..."

mdadm --detail $RAID | grep sd | awk '{print $7}' | while read LINE; do
	mdadm $RAID --fail $LINE --remove $LINE > /dev/null 2&>1
	mdadm --zero-superblock $LINE > /dev/null 2&>1
done

echo "done."

# Delete the array from the system completely
echo -n "Removing $RAID..."
mdadm --remove $RAID > /dev/null 2&>1
echo "done."

# Below should show nothing
echo "mdstat output:"
cat /proc/mdstat | grep -v "unused devices" | grep -v "Personalities"
