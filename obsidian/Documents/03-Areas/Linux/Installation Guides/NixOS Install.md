# NixOS install
NixOS is a Linux distribution in where the packages and configurations are stored in a declarative file. This allows for easy reproducibility and portability. Another feature of it is that if in an update something goes wrong, the previous version is stored so you can rollback safely
## DIFFICULTY LEVEL
7/10.
The first time using it will be very hard, but once you get used to it, is easier than other distros like Arch or Gentoo.
## INSTALLATION
This installation guide assumes that:
- The system is 64 bit
- The system is using the Minimal ISO
- The system is using an ethernet connection
- The system will not dual-boot with other OSes
- The disk will not be encrypted
- The user will not use any flakes or home manager features
### ACQUIRING THE IMAGE
Download the image and verify it to check if it's legitimate. Copy the image into an usb and then restart the computer.
### BOOTING INTO THE IMAGE
Upon booting the live image, you will login as `nixos`. You can easily change to root using:
```bash
sudo -i
```
Change your keyboard layout with `loadkeys` and test the connectivity with
```bash
ping -c 3 1.1.1.1
```
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
- Root partition: EXT4 filesystem with the rest of the disk space

To completely wipe out the disk you'll be using for NixOS, type:
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
We need now to format the partitions. NixOS recommends using labels to make the file system configuration independent from device changes.
- Root partition: `mkfs.ext4 -L nixos /dev/nmveXnYpZ`
- Boot partition: `mkfs.fat -F 32 -n boot /dev/nvmeXnYpZ`
- Swap partition: `mkswap -L swap /dev/nvmeXnYpZ`

Afterwards, we need to mount them. First, mount the root partition with:
```bash
mount /dev/disk/by-label/nixos /mnt
```
and the boot one with:
```bash
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```
### NIXOS CONFIG GENERATION
Now we need to generate a basic NixOS config file, which will store all configurations and packages
```bash
nixos-generate-config --root /mnt
```
A basic configuration file is more or less like this
```bash
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  boot.loader.systemd-boot.enable = true;
}
```
#### SETTING THE BOOTLOADER
The guide assumes systemd-boot. Add these two lines to the config file
```bash
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
```
Do the install with
```bash
nixos-install
```
Type the password for the root account.
#### ENABLING NETWORKING
To enable networking (ethernet and wireless), add the following line
```bash
networking.networkmanager.enable = true;
```
## FIRST BOOT AND POST-CONFIGURATIONS
After completing the installation, exit the chroot and unmount remaining disks
```bash
exit
cd
umount -R /mnt
reboot 
```
If everything went OK, you have installed NixOS successfully.
### ADDING A USER
Add these to the config file
```bash
users.users.luis = {  
isNormalUser = true;  
extraGroups = [  
"wheel"  
"networkmanager"  
];  
};
```
Apply the configuration with
```bash
sudo nixos-rebuild switch
```
and check the user is created with
```bash
id luis
```
Set the password with `passwd luis`
## MANTEINANCE
### NIXOS GENERATIONS
These are snapshots used to rollback to them everytime an update goes wrong.
A good practice is to limit the number of them available at boot to 5 and automatically delete generations that are older than 30 days.
```bash
boot.loader.systemd-boot.configurationLimit = 5;

nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};
```
## CONCLUSIONS
NixOS is a Linux distribution that advanced user can use and install if they want a reproducible system.








