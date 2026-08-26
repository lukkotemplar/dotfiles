# Arch Linux install
Arch Linux is a Linux distribution which gives you a very minimal base system from where you install everything. It is a rolling release distro, so everything is almost up to date.
## DIFFICULTY LEVEL
6/10.
Although not a very hard installation, its rolling release nature makes it easy to break. An arch user should be very wary of the packages in its system and be prepared to solve every kind of problem.
## INSTALLATION
This installation guide assumes that:
- The system is 64 bit
- The system is using an ethernet connection
- The system will not dual-boot with other OSes
- The disk will not be encrypted
### ACQUIRING THE IMAGE
Download the image and verify it to check if it's legitimate. Copy the image into an usb and then restart the computer.
### BOOTING INTO THE IMAGE
Upon booting a tty console will appear. It will prompt the user to execute the automated installator, `archinstall`, but that is outside the scope of this guide.
### INITIAL CONFIGURATIONS
We will set the keyboard layout with
```bash
loadkeys <layout>
```
Test basic connectivity with:
```bash
ping -c 3 1.1.1.1
```
and update the clock with:
```bash
timedatectl
```
If everything's ok, proceed with the disks
### PREPARING THE DISKS
In Linux, disks are commonly represented as block devices, and are special files in the /dev directory.
- /dev/sda: SATA disks, SCSI disks or USBs
- /dev/nvme0n1: NVMe disks
- /dev/mmcblk0: embedded MMC devices, SD cards and other types of memory cards

There are also other, less common block devices.
Normally, block devices are separated into partitions.
- /dev/sda1
- /dev/nvme0n1p1

These partitions are managed by a partition table, which can be of 2 types: GPT and MBR. Nowadays, GPT is the standard used, so we'll stick to that.
In a standard system (as of 2026), there are usually 3 partitions:
- Boot partition: FAT32 filesystem with 1 GB of space
- Swap partition: Linux swap with 4-8GB of space if you have 8GB or more of RAM, which is the common as of 2026 (8GB if you have more than 64 GB of RAM)
- Root partition XFS filesystem with the rest of the disk space

To completely wipe out the disk you'll be using for Arch, type:
```bash
nvme format /dev/nvmeXnY --ses 1
```
Use fdisk to write new partitions:
```bash
fdisk
# List the partitions
p
# Create a new gpt disklabel
g
# Create Boot Partition
n # New partition
<Enter> # Default first sector
+1G # Space
t # Change the partition type
1 # Change partition type to EFI System
r # Exit
# Create Swap
n # New partition
2 # Second partition
<Enter> # Default first sector
+XG # Space
t # Change the partition type
19 # Change partition type to Swap
r # Exit
# Create Root
n # New partition
3 # Third partition
<Enter># Default first sector
<Enter> # Remainder of the space
t # Change the partition type
23 # Change partition type to Linux root (x86-64)
r # Exit
p # List partitions, checking everything is OK
w # Write all changes
```
### FORMATING AND MOUNTING THE PARTITIONS
We need now to format the partitions.
- Root partition: `mkfs.ext4 /dev/nmveXnYpZ`
- Boot partition: `mkfs.vfat -F 32 /dev/nvmeXnYpZ`
- Swap partition: `mkswap /dev/nvmeXnYpZ && swapon /dev/nvmeXnYpZ`

Afterwards, we need to mount them. Mount the root partition with:
```bash
mount /dev/nvmeXnYpZ /mnt
```
and the boot partition with
```bash
mount --mkdir /dev/nvmeXnYpZ /mnt/boot
```
Enable the swap partition with
```bash
swapon /dev/nvmeXnYpZ
```
### MIRRORS
Edit the `/etc/pacman.d/mirrorlist` file and uncomment the closest mirrors to where you live
### INSTALLING THE SYSTEM
Now it's time to install the base system. There isn't a recommended list of packages, but you should consider at least adding:
- `base`: Minimal arch metapackage with bash, coreutils, systemd...
- `linux`: Official linux kernel. Unless you have another kernel (either precompiled or manual), stick with this one
- A bootloader of your choice (grub or systemd-boot)
- A text editor of your choice (vim or nano)

Additional packages are:
- `networkmanager`: Manages the network. Although it can be omitted (if you only plan to use ethernet), installing it makes it easier to manage network connections
- Binary firmware for Intel, AMD, or other vendors. For intel, `linux-firmware-intel`. It can be omitted, but if some hardware requires external firmware, it should be installed
- Packages for audio support like `pipewire` or `pulseaudio`. Additionally, some audio cards may require `sof-firmware`
- Some other packages for programming, managing filesystems, etc...

When considering packages, think of adding only the necessary ones for the system to boot
This is perhaps the most interesting Arch aspect. You decide what's going to be installed on the system, and the system tells you exactly what is going to have.
Install the packages with
```bash
pacstrap -K /mnt base linux ...
```
### CONFIGURING THE SYSTEM
#### FSTAB
To get needed file systems mounted on startup we need to generate an fstab file.
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
#### CHROOTING
Enter the new environment with
```bash
arch-chroot -S /mnt
```
Notice that some commands will be disabled now, such as `timedatectl`,`hostnamectl`...
#### TIMEZONE AND LOCALES
Set the timezone with
```bash
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
```
To set the localization, uncomment the desired locales in the `/etc/locale.gen` and execute
```bash
locale-gen
```
Create `/etc/locale.conf`, and set the variable `LANG` to the desired locale. Additionally, set the variable `LC_MESSAGES` if you want to use the locales in a language but the text in other.
```bash
LANG=es_ES.UTF-8
LC_MESSAGES=en_GB.UTF-8
```
Set the keymap in `/etc/vconsole.conf`
```bash
KEYMAP=es
```
#### HOSTNAME
Set the hostname in `/etc/hostname`
```bash
archbtw
```
#### BOOT AND FINAL CONFIGURATIONS
Reload the config of the Arch Linux *initramfs*
```bash
mkinitcpio -P
```
Set the root password with
```bash
passwd
```
and enable NetworkManager (if using it)
```bash
systemctl enable NetworkManager
```
Finally, install the bootloader. The guide assumes you're using `systemd-boot`.
Check if this directory exists.
```bash
ls /sys/firmware/efi/efivars
```
Execute
```bash
bootctl install
```
and create the menu in `/boot/loader/loader.conf`
```bash
cat > /boot/loader/loader.conf <<'EOF'
default arch.conf
timeout 3
console-mode keep
editor no
EOF
```
Obtain the UUID of the root partition and create `/boot/loader/entries/arch.conf`
```bash
ROOT_UUID=$(findmnt -no UUID /)

cat > /boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$ROOT_UUID rw
EOF
```
Check everything's OK
```bash
bootctl status
bootctl list # Output: Arch Linux
ls /boot # Output: EFI, loader, vmlinuz-linux...
```
## FIRST BOOT AND POST-CONFIGURATIONS
After completing the installation, exit the chroot and unmount remaining disks
```bash
exit
umount -R /mnt
reboot 
```
If everything went OK, you have installed Arch successfully.
### ADDING A USER
```bash
useradd -m -G users,wheel,<othergroups...> -s /bin/bash spongebob
passwd spongebob
```
To allow that user to have root privileges, install the package `sudo` and edit the sudoers file to allow access to wheel users.
Otherwise, use the su - command.
## MANTEINANCE
Arch manteinance should be done daily.
Update packages with
```bash
pacman -Syu
```
and clean unused dependencies with
```bash
pacman -Qdtq
pacman -Rns $(pacman -Qdtq)
```
## CONCLUSIONS
Arch Linux is a Linux distribution that an advanced user can use and install if they want a clean system and up-to-date-programs







