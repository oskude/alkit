#!/usr/bin/bash

ExitIfDiff $# 3 <<-EOU
	shortcut to run alkit zap, mount and strap
	usage:
	   clone <template> <disk> <mnt>
	args:
	   template   path to template directory
	   disk       path to disk device
	   mnt        path to mount point
EOU

template="$1"
disk="$2"
mnt="$3"

if ! CallIfExists "zap" "$template" "$disk"
then
	$alkit_cmdir/zap.sh "$template" "$disk"
fi

if ! CallIfExists "mount" "$template" "$disk" "$mnt"
then
	$alkit_cmdir/mount.sh "$template" "$disk" "$mnt"
fi

if ! CallIfExists "strap" "$template" "$mnt"
then
	$alkit_cmdir/strap.sh "$template" "$mnt"
fi
