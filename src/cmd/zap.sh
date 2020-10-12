ExitIfDiff $# 2 <<-EOU
	partition and format disk according to etc/fstab
	usage:
	   zap <template> <disk>
	args:
	   template   path to template directory
	   disk       path to disk device
EOU

template="$1"
disk="$2"
part_prefix=""

declare -a disksetup
GetDiskSetup "$template" "disksetup"

ExitIfLess ${#disksetup[@]} 1 <<-EOE
	ERROR: no disk setup found
EOE

AskRun sgdisk "$disk" --zap-all

if [[ "$disk" =~ ^/dev/loop* ]]; then
	part_prefix="p"
elif [[ "$disk" =~ ^/dev/nbd* ]]; then
	part_prefix="p"
fi

for d in "${disksetup[@]}"
do
	declare fld=($d)
	declare label=${fld[1]}
	declare mnt=${fld[2]}
	declare size=${fld[4]}
	declare type="8300"
	[[ $mnt == "/boot" ]] && type="EF00"
	[[ $mnt == "/" ]]     && type="8304"
	AskRun sgdisk "$disk" -n 0:0:+${size}GB -t 0:$type -c 0:$label
done

for d in "${disksetup[@]}"
do
	declare fld=($d)
	declare nr=${fld[0]}
	declare format=${fld[3]}
	AskRun mkfs.$format ${disk}${part_prefix}${nr}
done
