#!/bin/bash

if [ $# -eq 0 ]; then
	read -p "No specific mount point provided.  Stop all arrays? (y/n): " CHOICE

	case $CHOICE in
	N|n)
		echo "Not stopping any arrays.  Exiting."
		exit 1
		;;
	*)
		echo "Stopping all arrays..."
		;;
	esac
else
	umount ${1}p1
	mdadm --stop $1

	exit 0
fi

# Simply reads each line from mdadm.conf (should only be arrays)
cat /etc/mdadm/mdadm.conf | while read LINE; do
	# Get the device info (/dev/md/0), and remove the last "/"
	# This is done to make the below mdadm work
	dev=$(echo -n $LINE | awk '{print $2}' | sed "s/\(.*\)\//\1/")

	umount "${dev}p1"

	mdadm --stop $dev
done

exit 0
