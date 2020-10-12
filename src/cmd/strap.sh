#!/usr/bin/bash

ExitIfDiff $# 2 <<-EOU
	pacstrap system according to .alkitpkgs
	usage:
	   strap <template> <system>
	args:
	   template   path to template directory
	   system     path to system directory
EOU

template="$1"
system="$2"
args="-cM"
pkgs="base"

if [[ -e "$template/etc/pacman.conf" ]]
then
	args="${args}C $template/etc/pacman.conf"
fi

if [[ -e "$template/.alkitpkgs" ]]
then
	pkgs=$(grep -v '^#' "$template/.alkitpkgs")
fi

AskRun pacstrap $args "$system" $pkgs
