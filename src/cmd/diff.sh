#!/usr/bin/bash

ExitIfDiff $# 2 <<-EOU
	show difference of template files in system
	usage:
	   diff <template> <system>
	args:
	   template   path to template directory
	   system     path to system directory
EOU

template="$1"
system="$2"

for path in $(ListTemplateFiles "$template")
do
	tplpath="${template}/${path}"
	syspath="${system}/${path}"
	echo "[ FILE ] $path"

	if [[ -e "$syspath" ]]; then
		tpl_mode=$(stat -c "%a" "$tplpath")
		sys_mode=$(stat -c "%a" "$syspath")
		if [[ $tpl_mode -ne $sys_mode ]]; then
			echo "MODE: $tpl_mode != $sys_mode"
		fi
	fi

	if [[ -L $tplpath ]]; then
		tpl_link=$(readlink "$tplpath")
		sys_link=$(readlink "$syspath")
		if [[ $tpl_link != $sys_link ]]; then
			echo "SYMLINK: $tpl_link != $sys_link"
		fi
	else
		diff -Nu "$syspath" "$tplpath"
	fi
done
