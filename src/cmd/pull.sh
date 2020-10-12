#!/usr/bin/bash

ExitIfDiff $# 2 <<-EOU
	pull template files from system
	usage:
	   pull <template> <system>
	args:
	   template   path to template directory
	   system     path to system directory
EOU

template="$1"
system="$2"

CopyFiles "PULL" "$system" "$template"
