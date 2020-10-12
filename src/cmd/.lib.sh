AskRun(){
	local cmdline=$@
	local reply=""
	local prompt="[ y/N? ] $cmdline"
	local newlines=$(expr ${#prompt} / $(tput cols))

	read -n 1 -rsp "$prompt" reply
	# TODO: bug or feature? `tput cuu 0` moves up one row!
	[[ "$newlines" -gt 0 ]] && tput cuu $newlines
	echo -en "\r"

	if [[ $reply =~ ^[yY]$ ]]; then
		echo "[  DO  ] $cmdline"
		$cmdline
	else
		echo "[ SKIP ] $cmdline"
	fi
}

DoRun(){
	local cmdline=$@
	echo "[  DO  ] $cmdline"
	$cmdline
}

GetDiskSetup(){
	local template="$1"
	local -n output="$2"
	local file="$1/etc/fstab"
	local nr=1
	local line
	[[ ! -e "$file" ]] && return 1
	while read line
	do
		[[ -z "$line" ]] && break
		[[ ! "$line" =~ ^PARTLABEL ]] && continue
		local -a field=($line)
		local lab=${field[0]##*=}
		local mnt=${field[1]}
		local fmt=${field[2]}
		local siz=${field[4]}
		output+=("$nr $lab $mnt $fmt $siz")
		((nr++))
	done < "$file"
}

CopyFiles(){
	local path
	for path in $(ListTemplateFiles "$2")
	do
		local cmdname="$1"
		local inppath="${2}/${path}"
		local outpath="${3}/${path}"

		echo "[ $cmdname ] $path"
		mkdir -p "${outpath%/*}"

		if [[ $(PathFsType "$outpath") == "msdos" ]]; then
			cp "$inppath" "$outpath"
			continue
		fi

		if [[ -L $inppath ]]; then
			ln -sf "$(readlink ${inppath})" "$outpath"
		else
			cp "$inppath" "$outpath"
		fi
	done
}

ListTemplateFiles(){
	local template="$1"
	local path
	shopt -s globstar
	for path in "$template"/*/**
	do
		[[ -d "$path" ]] && continue
		echo "${path#$template}"
	done
}

PathFsType(){
	local path="/$1"
	until [[ -e "$path" ]]; do
		path="${path%/*}"
		if [[ -z "$path" ]]; then
			return
		fi
	done
	stat -f -c %T "$path"
}

CallIfExist(){
	local func="$1"; shift
	if [[ $(type -t $func) == "function" ]]
	then
		echo "[.alkit] $func START"
		$func $@
		echo "[.alkit] $func END"
		return 0
	fi
	return 1
}

SourceIfExist(){
	[[ -e "$1" ]] && source "$1"
}

IfYes(){
	local msg="$1"
	read -n 1 -rsp "## $msg (y/N) " reply
	echo $reply
	[[ $reply =~ ^[yY]$ ]] && return 0
	return 1
}

ExitIfNotExist(){
	if [[ ! -e "$1" ]]
	then
		cat /dev/stdin
		exit 0
	fi
}

ExitIfEmpty(){
	if [[ -z "$1" ]]
	then
		cat /dev/stdin
		exit 0
	fi
}

ExitIfDiff(){
	if [[ $1 -ne $2 ]]
	then
		cat /dev/stdin
		exit 0
	fi
}

ExitIfLess(){
	if [[ $1 -lt $2 ]]
	then
		cat /dev/stdin
		exit 0
	fi
}
