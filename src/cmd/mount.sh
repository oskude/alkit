#!/usr/bin/bash

ExitIfDiff $# 3 <<-EOU
	mount disk according to etc/fstab
	usage:
	   mount <template> <disk> <mount>
	args:
	   template   path to template directory
	   disk       path to disk device
	   mount      path to mount point
EOU

template="$1"
disk="$2"
mount="$3"
part_prefix=""

declare -a ds
GetDiskSetup "$template" "ds"

ExitIfLess ${#ds[@]} 1 <<-EOE
	ERROR: no disk setup found
EOE

if [[ "$disk" =~ ^/dev/loop* ]]; then
	part_prefix="p"
elif [[ "$disk" =~ ^/dev/nbd* ]]; then
	part_prefix="p"
fi

# first mount /
for d in "${ds[@]}"
do
	declare fld=($d)
	declare nr=${fld[0]}
	declare mnt=${fld[2]}
	if [[ $mnt == "/" ]]
	then
		AskRun mount ${disk}${part_prefix}${nr} $mount$mnt
	fi
done

# then the rest
for d in "${ds[@]}"
do
	declare fld=($d)
	declare nr=${fld[0]}
	declare mnt=${fld[2]}
	if [[ $mnt != "/" ]]
	then
		if [[ ! -e $mount$mnt ]]
		then
			AskRun mkdir -p $mount$mnt
		fi
		AskRun mount ${disk}${part_prefix}${nr} $mount$mnt
	fi
done
