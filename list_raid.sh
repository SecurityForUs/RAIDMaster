#!/bin/bash

echo "[>>] List RAID devices"

echo "[>>] Below are the known RAID devices on this sytem:"
cat /proc/mdstat | while read LINE; do
	LINE=$(echo -n "$LINE" | grep '^m')

	if [ -n "$LINE" ]; then
		LINE=$(echo -n "$LINE" | awk '{printf "/dev/%s [status: %s]", $1, $3}')
		echo "$LINE"
	fi
done
