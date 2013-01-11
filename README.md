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
* No error checking is done yet on ensuring RAID levels and disk information are proper (i.e.: unless mdadm doesn't let you, you can pass one disk for a RAID 10 and it wouldn't detect it as wrong)

Passing Arguments via raid.sh
=============================
If you plan on using raid.sh for just one command, you can pass 
arguments to raid.sh and they will be sent to the selected script.

If you are not sure what arguments to pass to a script, just run it 
without any, and if it takes some it will prompt you.
(side-note: I don't think all scripts do right at this moment, more of a WIP, but most of them should)

How to Run
==========
Whenever a new feature or whatnot is added to this project, raid.sh is 
updated accordingly.  If you don't want to use the "central console" of 
this suite, just run whatever script you want.  Here are the current 
scripts and what they do:

* convert_raid.sh - Changes the RAID level (or attempts to)
* create_raid.sh - Creates an array (mandatory prompts involved)
* grow_raid.sh - Expands an array by adding additional disk(s) to it
* list_raid.sh - Simply lists all active arrays on the system
* raid.sh - Central console used to make this (semi) easier
* remove_drives_raid.sh - Removes drive(s) fron an array, shrinking it
* remove_raid.sh - Completely removes array from RAID system
* start_raid.sh - Startup script for arrays
* stop_raid.sh - Stops all (specific) arrays from running anymore
