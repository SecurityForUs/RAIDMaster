#!/bin/bash

declare -a mounts=("${@}")

((count=${#mounts[@]}, count=count - 1))

if [ $# -eq 0 ]; then
	echo "Usage: $0 <space-separated mount points for arrays>"
	echo "No mount points provided, prompted at each mount"
fi

pos=0

# Simply reads each line from mdadm.conf (should only be arrays)
cat /etc/mdadm/mdadm.conf | while read LINE; do
	# Get the device info (/dev/md/0), and remove the last "/"
	# This is done to make the below mdadm work
	dev=$(echo -n $LINE | awk '{print $2}' | sed "s/\(.*\)\//\1/")

	# Get the UUID of the device (in the event of multiple arrays)
	# Probably not necessary, but still a nice sort of safety net to have
	uuid=$(echo -n $LINE | awk '{print $4}' | awk -F'=' '{print $2}')

	# Assemble the array and mount it so to speak to the system
	mdadm --assemble --scan $dev --uuid=$uuid

	if (( count < 0 )); then
		read -p "Enter mountpoint for ${dev}p1: " mp < /dev/tty
	else
		echo "[>>] making mount point ${mounts[pos]} for $dev"
		mp="${mounts[pos]}"
	fi

	if [ -z "$mp" ]; then
		echo "[!!] No mount point provided for ${dev}p1...skipping."
	else
		# Mount the array partition to disk
		mount "${dev}p1" "$mp"

		# Show first 10 lines of ls -liha on mount point
		echo "> Preview of $mp..."
		ls -liha "$mp" | head -n 10

		# Move forward in mount point array
		let pos++
	fi
done
