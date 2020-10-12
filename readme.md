# `alkit`

given that we have this wonderful "everything is a file" thing, i sure do wanna have my (hobby desktop) system - _or rather, only the files i need/want_ - also in git! but managing .git in / was not so fun. so what if we took the "git workflow" and applied it to just syncing two directories, a template and the system. add some helpers and bang! [kiss](example/readme.md)?

> **WARNING: this is some dangerous(powerful) ~~sh~~script, so please do not run on a system you cannot easily restore/forget. cause i would feel really bad if my code broke your system, mmmkay.**

Command | Arguments | Description
--------|-----------|------------
`status` | `<template> <system>` | _show status of template files in system_
`diff` | `<template> <system>` | _show difference of template files in system_
`pull` | `<template> <system>` | _pull template files from system_
`push` | `<template> <system>` | _push template files to system_
`zap` | `<template> <disk>` | _partition and format disk according to template_
`mount` | `<template> <disk> <mnt>` | _mount disk according to template_
`strap` | `<template> <system>` | _pacstrap system according to template_
`clone` | `<template> <disk> <mnt>` | _shortcut to run `zap`, `mount` and `strap`_

<br>

## Template

a standard "linux" directory tree , and a couple custom files in the root.

### `*/**`

all non-hidden sub-directories are used as system files.

### `etc/fstab`

as fstab already has the partition format and path for mounting, i could not resist to re-purposed the 5th field - _that i have never seen being used_ - as size for the partition...

- only first lines till empty line are considered by `alkit`
- only lines that start with `PARTLABEL` are used
- order of lines define order of partition on disk
- 1st field is used for parition label by `zap`
- 2nd field is used for mounting by `mount`
- 3th field is used for formatting by `zap`
- 5th field is used for partition size by `zap` (gigabytes (0 is the rest))

### `.alkitpkgs`

a plain text file that lists packages to install with `strap`:

```
base
linux
```

> lines that start with `#` are ignored

### `.alkit`

an optional bash script with custom functions for the `alkit` commands:

- `<command>` replace default command
- `before_<command>` run before command is run
- `after_<command>` run after command is run

all these functions get the command arguments in the same order, for example:
```
after_clone(){
	local template="$1"
	local disk="$2"
	local mnt="$3"
	AskRun arch-chroot $mnt locale-gen
	AskRun arch-chroot $mnt mkinitcpio -p linux
}
```
> `AskRun` is a function to confirm a command. see [`src/.lib.sh`](src/.lib.sh) for more helpers.
