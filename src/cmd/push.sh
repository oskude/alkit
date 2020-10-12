#!/usr/bin/bash

ExitIfDiff $# 2 <<-EOU
	push template files to system
	usage:
	   push <template> <system>
	args:
	   template   path to template directory
	   system     path to system directory
EOU

template="$1"
system="$2"

CopyFiles "PUSH" "$template" "$system"
