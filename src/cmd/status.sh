#!/usr/bin/bash

ExitIfDiff $# 2 <<-EOU
	show status of template files in system
	usage:
	   status <template> <system>
	args:
	   template   path to template directory
	   system     path to system directory
	statuses:
	   [  OK  ]   files are identical
	   [ MISS ]   file does not exist in system
	   [ DIFF ]   file content does not match
	   [ MODE ]   file modes do not match
	   [ LINK ]   file symlink does not match
EOU

template="$1"
system="$2"

for path in $(ListTemplateFiles "$template")
do
	tplpath="${template}/${path}"
	syspath="${system}/${path}"

	if [[ ! -e "$syspath" ]]; then
		echo "[ MISS ] $path"
		continue
	fi

	if [[ $(diff -q "$tplpath" "$syspath" ) ]]; then
		echo "[ DIFF ] $path"
		continue
	fi

	if [[ $(PathFsType "$syspath") != "msdos" ]]
	then
		if [[ $(stat -c "%a" "$tplpath") -ne $(stat -c "%a" "$syspath") ]]; then
			echo "[ MODE ] $path"
			continue
		fi
		if [[ -L $tplpath ]]; then
			if [[ $(readlink "$tplpath") != $(readlink "$syspath") ]]; then
				echo "[ LINK ] $path"
				continue
			fi
		fi
	fi

	echo "[  OK  ] $path"
done
