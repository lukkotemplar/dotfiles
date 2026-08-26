# Managing partitions
When installing a Linux distro, you must prepare the disk with the correct partitions in order for it to work with your new system.
There are 3 different cases when installing Linux and therefore 3 ways to prepare your disk.
>[!info]
>For simplicity, the guide will use the notation /dev/XXX for disks and /dev/XXXYYY for partitions

Also, there are 2 different cases depending if you are in a TTY or in a GUI program
# TTY
## NO PREVIOUS OS
### CREATING PARTITIONS
You can simply delete the disk and create new partitions.
Type:
```bash
cfdisk /dev/XXX
```
If your disk has no partition table, it will ask you to select one.
> [!info] 
> This guide assumes you are using GPT as your partition table

After selecting GPT, a TUI menu will appear. Navigate with the arrow keys and select New.
#### BOOT PARTITION
`cfdisk` will ask you for the space of the new partition. Type `1G` or `512M` and press enter.
This will be your boot partition, used to launch your OS.
#### SWAP PARTITION (OPTIONAL)
A swap partition is a disk space that Linux uses in the event you run out of RAM as auxiliary memory, being also used to enable hibernation on your system.
Its size depends on two factors: which RAM you have and if you want to enable hibernation. Although there's no "perfect" size, a good recommendation would be this:

|   RAM | No hibernation | With hibernation |
| ----: | -------------: | ---------------: |
|  4 GB |         4–8 GB |           6–8 GB |
|  8 GB |         4–8 GB |          8–12 GB |
| 16 GB |         4–8 GB |         16–20 GB |
| 32 GB |         4–8 GB |         32–36 GB |
| 64 GB |         4–8 GB |      64 GB o más |
You'll probably notice the seemingly unusual space for hibernation systems with large amounts of RAM. This is because when a system hibernates it copies the RAM to disk. That's why the Gentoo handbook doesn't recommend hibernation for systems with 64GB or more of RAM.
Do the same steps as with [[#BOOT PARTITION]] and type your swap space instead of 1 GB or 512 MB.
#### ROOT PARTITION
This is the partition of your Linux filesystem. Use the remaining space available on your disk (hitting enter when prompted about the partition size) or a fixed space if you want to install more Linux distros later.
#### WRITING CHANGES
>[!info]
>There are some cases in which you may want to create a /home partition. At the moment this is outside the scope of this guide, and in the future will be updated to include that case :)

Once you have all your partitions created, navigate with the arrow keys and hit enter on Write.
>[!warning]
>All your data in the disk will be erased!
### FORMATTING PARTITIONS
After writing the partitions, you will need to format them with a filesystem type
#### BOOT PARTITION
It will be formatted as FAT32, which is the usual as of creating this guide.
Type:
```bash
mkfs.fat -F 32 /dev/XXXYYY
```
#### SWAP PARTITION (OPTIONAL)
If you [[#SWAP PARTITION (OPTIONAL)|created]] a swap partition:
```bash
mkswap /dev/XXXYYY
```
#### ROOT PARTITION
##### NON-ENCRYPTED DISK
```bash
mkfs.ext4 /dev/XXXYYY
```
>[!info]
>You can choose another filesystem such as btrfs or xfs. For simplicity, we will use ext4
##### ENCRYPTED DISK
Check this section on managing encrypted disks.
### MOUNTING PARTITIONS
After formatting, you need to mount the partitions.
#### ROOT PARTITION
##### NON-ENCRYPTED DISK
```bash
mount /dev/XXXYYY /path/to/mount
```
#### BOOT PARTITION
```bash
mount /dev/XXXYYY /path/to/mount
```
#### SWAP PARTITION
```bash
swapon /dev/XXXYYY
```
##### ENCRYPTED DISK
Check this section on managing encrypted disks.
## PREVIOUS LINUX
### CREATING PARTITIONS
You should already have these partitions (check with `lsblk`):
- Boot partition (its format and size should be quite similar to the one you [[#CREATING PARTITIONS|create]])
- Swap partition (if you created it in the other Linux installation)
- Root partition of the other Linux OS

Just [[#CREATING PARTITIONS|create]] the new root partition for your system with `cfdisk`.
>[!warning]
>Don't touch the other partitions, otherwise the other Linux may be unable to boot later
### FORMATTING PARTITIONS
Just [[#FORMATTING PARTITIONS|format]] the new root partition you just created
### MOUNTING PARTITIONS
[[#MOUNTING PARTITIONS|Mount]] only the new root partition and later the already existing boot.
## PREVIOUS WINDOWS
It will have its partitions such as Recovery or Microsoft Reserved.
Proceed the same as [[#PREVIOUS LINUX|here]]. In this case, you will mount the boot partition of Windows (if it says EFI or ESP, it's the same).
# GUI
## NO PREVIOUS OS
#### ERASE DISK
Many installers offer this option. It's the safest one (as it does the partitioning, formatting and mounting for you), but it may not write partitions as you expected.
#### MANUAL PARTITIONING
Proceed the same as [[#NO PREVIOUS OS|here]], with a few changes:
- The mountpoint of the boot partition may not be available for you to choose (depends on the distro, most of them use `/boot/efi`)
- Fedora is unique in the way that it needs a separate `/boot` partition in addition to the one described [[#BOOT PARTITION|here]]. Its size is 1GB-2GB, and is mounted on `/boot` (the other one being in `/boot/efi`).
## PREVIOUS LINUX AND WINDOWS
Some systems offer the option to install your new distro alongside Linux or Windows. Although is a good option if you don't want to get dirty, it may overwrite your boot partition.
Proceed the same as [[#PREVIOUS LINUX|here]].