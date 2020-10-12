# `alkit` example <!-- omit in toc -->

this directory is an example [`alkit`](../readme.md) template that defines a minimal booting (arch linux) system.

this (for alkit irrelevant) document provides some examples on using the tool, and is structured so that you can follow it step-by-step, to re-create the files in this template.

- [Defaults](#defaults)
- [Setup the disk](#setup-the-disk)
- [Install system packages](#install-system-packages)
- [Create template files](#create-template-files)
- [Manage system files](#manage-system-files)
- [The great workaround](#the-great-workaround)
- [Boot the disk](#boot-the-disk)
- [Have Fun](#have-fun)

<br>

## Defaults

running `alkit` without arguments shows quick help:

```
> alkit
alkit 0.1
manage system from template
usage:
   alkit <command> <arguments>
commands:
   status   show status of template files in system
   diff     show difference of template files in system
   pull     pull template files from system
   push     push template files to system
   zap      partition and format disk according to etc/fstab
   mount    mount disk according to etc/fstab
   strap    pacstrap system according to .alkit
   clone    shortcut to run zap, mount and strap
```

as does every `alkit <command>`:
```
> alkit status
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
```

some `alkit` commands ask for confirmation for their tasks:

```
> alkit mount . /dev/loop0 /mnt
[ y/N? ] mount /dev/loop0p2 /mnt/
```

you can allow the task by pressing key "y":

```
[  DO  ] mount /dev/loop0p2 /mnt/
```

or any other key to skip:

```
[ SKIP ] mount /dev/loop0p2 /mnt/
[ SKIP ] mkdir -p /mnt/boot
[ SKIP ] mount /dev/loop0p1 /mnt/boot
```
> useful for non-sudo preview of all command tasks

<br>

## Setup the disk

choose your disk wisely, or use a raw disk image:

```
> fallocate -l 3G disk.example
> sudo losetup --find --show --partscan disk.example
/dev/loop0
```

in any case, `etc/fstab` defines the disk:

```
> $EDITOR etc/fstab
PARTLABEL=EXAMPLE_BOOT /boot vfat rw,noatime 1
PARTLABEL=EXAMPLE_ROOT /     ext4 rw,noatime 0
```

`zap` creates the disk:

```
> sudo alkit zap . /dev/loop0
[  DO  ] sgdisk /dev/loop0 --zap-all
Creating new GPT entries in memory.
GPT data structures destroyed! You may now partition the disk using fdisk or
other utilities.
[  DO  ] sgdisk /dev/loop0 -n 0:0:+1GB -t 0:EF00 -c 0:EXAMPLE_BOOT
Creating new GPT entries in memory.
Setting name!
partNum is 0
The operation has completed successfully.
[  DO  ] sgdisk /dev/loop0 -n 0:0:+0GB -t 0:8304 -c 0:EXAMPLE_ROOT
Setting name!
partNum is 1
The operation has completed successfully.
[  DO  ] mkfs.vfat /dev/loop0p1
mkfs.fat 4.1 (2017-01-24)
[  DO  ] mkfs.ext4 /dev/loop0p2
mke2fs 1.45.6 (20-Mar-2020)
Discarding device blocks: done
Creating filesystem with 524027 4k blocks and 131072 inodes
Filesystem UUID: a6243742-8f28-4973-8a50-702358bce3b4
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

and `mount` does what mount does:

```
> sudo alkit mount . /dev/loop0 /mnt
[  DO  ] mount /dev/loop0p2 /mnt/
[  DO  ] mkdir -p /mnt/boot
[  DO  ] mount /dev/loop0p1 /mnt/boot
```

<br>

## Install system packages

system packages are listed in `.alkitpkgs` file:

```
> $EDITOR .alkitpkgs
base
linux
```

and `strap` is used to install them to the system:

```
> sudo alkit strap . /mnt
[  DO  ] pacstrap -cM /mnt base linux
==> Creating install root at /mnt
==> Installing packages to /mnt
...
```

<br>

## Create template files

we symlink some uefi boot loader:

```
> mkdir -p boot/efi/boot
> ln -s /usr/lib/systemd/boot/efi/systemd-bootx64.efi boot/efi/boot/bootx64.efi
```

and configure the boot loader:
```
> $EDITOR boot/loader/entries/default.conf
title   example
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=PARTLABEL=EXAMPLE_ROOT rw
```

<br>

## Manage system files



```
> alkit status . /mnt
[ MISS ] /boot/efi/boot/bootx64.efi
[ MISS ] /boot/loader/entries/default.conf
[ DIFF ] /etc/fstab
```

> you could also use `alkit diff`, but the output is messy, and i haven't actually needed it yet, so...

```
> sudo alkit push . /mnt
[ PUSH ] /boot/efi/boot/bootx64.efi
[ PUSH ] /boot/loader/entries/default.conf
[ PUSH ] /etc/fstab
```
> note: as vfat does not support symlinks, `push` copies the link files content, instead the default of copying the symlink as symlink.

```
> alkit status . /mnt
[  OK  ] /boot/efi/boot/bootx64.efi
[  OK  ] /boot/loader/entries/default.conf
[  OK  ] /etc/fstab
```


<br>

## The great workaround

well, not everything is a (easy) file, or sometimes you want to run template specific commands (or you might even want to replace alkit commands... yup, i just killed many feature request, muahaha ;P). in this example we set the root password after `strap` is run.

```
> $EDITOR .alkit
after_strap(){
	system="$2"
	AskRun arch-chroot $system passwd
}
```

and `strap` the system again:

```
> sudo alkit strap . /mnt
sudo alkit strap . /mnt
[ SKIP ] pacstrap -cM /mnt base linux
[.alkit] after_strap START
[  DO  ] arch-chroot /mnt passwd
New password:
Retype new password:
passwd: password updated successfully
[.alkit] after_strap END
```
> as we didn't add new packages, no need to run pacstrap again.

<br>

## Boot the disk

at any stage you can test if the disk boots in a vm:

```
> qemu-system-x86_64 -drive if=pflash,format=raw,readonly,file=/usr/share/ovmf/x64/OVMF_CODE.fd -enable-kvm -cpu host -m 1G -snapshot -drive file=disk.example,format=raw
```

> note: `-snapshot` is important cause we still might have the `disk.example` image looped and mounted, so qemu won't write anything to the image.

<br>

## Have Fun

the rabbit hole might seem endless, but don't worry: it's all just files, [all the way down](http://www.linuxfromscratch.org/).
