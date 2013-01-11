RAIDMaster
==========

Collection of scripts to help with RAID management (creation, deletion, etc...)

Notices
=======

These scripts makes some assumptions, depending on which one is ran.

For example:

* All of these typically require root, which is assumed
* create_raid.sh creates an array on /dev/md#, which is what the rest expect
* remove_devices_raid.sh and grow_raid.sh try to set the new device amount, but is not fool-proof
