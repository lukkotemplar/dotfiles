# Gentoo install
Gentoo is a Linux distribution which unlike many others compiles the packages from their source code. This grants the ability to disable certain features of packages (such as bluetooth support) to tailor the system to the user's needs.
## DIFFICULTY LEVEL
9/10.
Due to the unique behavior of Gentoo, the user needs to have a complete knowledge of working with package dependencies and other aspects at a lower level than other distros (for example, configuring the network, installing a DE...). This makes Gentoo a very advanced system not for the common user's eye.
## INSTALLATION
This installation guide assumes that:
- The system is 64 bit
- The system is using the Live GUI
- The system is using an ethernet connection
- The system will not dual-boot with other OSes
- The disk will not be encrypted
### ACQUIRING THE IMAGE
Download the image and verify it to check if it's legitimate. Copy the image into an usb and then restart the computer.
### BOOTING INTO THE IMAGE
Upon booting the KDE Desktop will appear. Select your preferred keyboard layout and open a console.
### INITIAL CONFIGURATIONS
We will need to enter the root user with:
```bash
sudo su -
```
After that, change the password of root with:
```bash
passwd root
```
It is also a good practice to change the password of the live user, in case you get locked out
```bash
passwd gentoo
```
### NETWORK TEST
Test basic connectivity with:
```bash
ping -c 3 1.1.1.1
```
and test DNS resolution with:
```bash
curl --location gentoo.org --output /dev/null
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
- Root partition EXT4 filesystem with the rest of the disk space

To completely wipe out the disk you'll be using for Gentoo, type:
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

Afterwards, we need to mount them. First, create the directory /mnt/gentoo with:
```bash
mkdir -p /mnt/gentoo
```
and mount the root partition with:
```bash
mount /dev/nvmeXnYpZ /mnt/gentoo
```
Create the efi directory with:
```bash
mkdir -p /mnt/gentoo/efi
```
We'll mount the boot partition later.
### STAGE FILE
The initial Gentoo files are downloaded from it's Stage tarball. There are 3 main types of stage tarballs, and each one lets you choose between 2 init systems (OpenRC or Systemd):
- Default: Minimal stage tarball
- Desktop: Stage tarball with extra content, adapted to Gentoo installations that use GNOME or KDE (although that doesn't mean the default ones can't have a Desktop Environment)
- No-multilib: Stage tarball with only 64 bit libraries. Not recommended if you plan to migrate to a multilib system

For simplicity reasons, this guide assumes you chose OpenRC
Download the stage tarball and verification files (CONTENTS.gz, DIGESTS, .asc and .sha256) with
```bash
wget <linktotarball> <linktofiles...>
```
#### VERIFICATION
Verify the SHA512 checksum with
```bash
openssl dgst -r -sha512 <file.tar.xz>
```
And compare its output to the DIGESTS file, if it's the same, the checksum has passed.
Do the same with BLAKE2B512:
```bash
openssl dgst -r -blake2b512 <file.tar.xz>
```
Verify the SHA256 hash with
```bash
sha256sum --check <file.sha256>
```
Import the PGP signing keys into the user's session with:
```bash
gpg --import /usr/share/openpgp-keys/gentoo-release.asc
```
and verify the signature with:
```bash
gpg --verify stage3-amd64-<release>-<init>.tar.xz.asc stage3-amd64-<release>-<init>.tar.xz
gpg --output stage3-amd64-<release>-<init>.tar.xz.DIGESTS.verified --verify stage3-amd64-<release>-<init>.tar.xz.DIGESTS
gpg --output stage3-amd64-<release>-<init>.tar.xz.sha256.verified --verify stage3-amd64-<release>-<init>.tar.xz.sha256
```
#### INSTALLATION OF STAGE FILE
Once the stage file has been downloaded and verified, it can be extracted with:
```bash
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
```
### CONFIGURING COMPILE OPTIONS
This is when Gentoo's magic comes to life. We need to edit the compile options to optimize the system.
Edit the file `/mnt/gentoo/etc/portage/make.conf` and go to the line where it says COMMON_FLAGS.
Add two flags called -march and -mtune
- -march=CPU: Controls compatibility and instructions set for the desired CPU
- -mtune=CPU: Controls performance in a specific CPU

To check your native CPU use
```bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | grep mtune
```
And check the -mtune and -march flags. For Intel CPUs, it will be something ending in "lake".
Add these 2 flags with their attributes to the `make.conf` file
```bash
COMMON_FLAGS="-march=<CPU> -mtune=<CPU> -O2 -pipe"
```
Additional CPU flags can be added, but to a new variable called CPU_FLAGS_X86.
To list them, use the command
```bash
cpuid2cpuflags
```
And copy the output in the `make.conf` file.
```bash
CPU_FLAGS_X86="flag1 flag2 ... flagn"
```
Some other features, like [LTO (Link Type Optimization)](https://wiki.gentoo.org/wiki/LTO), can be added, but they're experimental.
Now we need to add the MAKEOPTS variable, which sets the parallel compilations when installing a package.
The syntax is `MAKEOPTS=-jX`, where X can be any number.
- A good number is the output of `nproc`, which returns the number of CPU threads in your computer

Add the variable to the `make.conf` with the desired number.
### BASE SYSTEM
We are now going to install the base system (not to confuse with the stage files, which we just downloaded and extracted). This is done by chrooting into the new environment
#### CHROOTING
First we need to copy the DNS info to ensure the network still works after entering the new environment:
```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc
```
Enter the environment with
```bash
arch-chroot /mnt/gentoo
```
You are now in the gentoo environment. Add the new settings and change the prompt as a visual indicator
```bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```
#### BOOTLOADER
We are going to mount the boot partition now. Create a directory in the root partition called efi and mount the partition there
```bash
mkdir /efi
mount /dev/nvme0n1p1 /efi
```
#### MIRRORS
In order to get better download speeds, we need to choose some mirrors for our system to use, using the package `app-portage/mirrorselect`.
To install it, first we need to get a snapshot of the Gentoo ebuild repository, which is more or less like the package repository of Gentoo.
```bash
emerge-webrsync
```
This can take a few minutes.
When it finishes, you will probably see a message like this
```bash
IMPORTANT: 15 news items need reading for repository 'gentoo'
```
Don't worry about it now, just install the package mentioned earlier with
```bash
emerge --ask --verbose --oneshot app-portage/mirrorselect
```
The output should be like this:
![[Pasted image 20260621130419.png]]
- N means that is a new package
- USE indicates the characteristics of the package (in red which features it will have, in blue which won't have)

Accept the installation and Gentoo will compile and install the package. Depending on the MAKEOPTS variable, it will take a while (you will need to get used to this), so wait.
With the program now installed, set the mirrors to use with
```bash
mirrorselect  -i -o >> /etc/portage/make.conf
```
A menu will open with the available mirrors. Select the ones from your country or near it and save it to the `make.conf` file
#### UPDATING 
Update the Gentoo ebuild repository with
```bash
emerge --sync
```
The news message will appear again. It is a good practice to read the news, for example, if something's wrong.
To list the news, type
```bash
eselect news list
```
The news will be listed like this
![[Pasted image 20260621131318.png]]
To read any news, type
```bash
eselect news read X
```
#### PROFILES
Profiles in gentoo are building blocks thay specify default values for USE, COMMON_FLAGS and other variables. To check which profiles are available, type
```bash
eselect profile list
```
Choose the desired one with
```bash
eselect profile set X
```
#### USE VARIABLE
The USE flags tells the system to disable (or enable) certain features so that new packages don't support those features (for example, `USE="-bluetooth"` disables bluetooth support). This is useful to reduce bloat and to further tailor the system to our needs.
To check all of the available default flags, type
```bash
emerge --info | grep ^USE
```
and copy and paste it as a comment in `make.conf`. That's not the actual list of USE flags, but rather common ones, as the real list is much larger.
If you want to check ALL the USE flags, open the file `/var/db/repos/gentoo/profiles/use.desc`
For example, to disable ipv6, ppp and dhcp:
```bash
USE="-ipv6, -ppp, -dhcpcd"
```
To check actual USE flags, type
```bash
portageq envvar USE
```
#### LICENSES
Some packages (especially NVIDIA or Steam), require special licenses that need to be accepted. 
![[Pasted image 20260621134147.png]]
Gentoo comes with @FREE.
Don't add anything right now. If a package requires a license, portage will indicate you where to include it.
#### UPDATING (AGAIN)
Before updating, we will clean obsolete packages. First, check it with
```bash
emerge --ask --pretend --depclean
```
to see we don't break anything. If everything is okay, run
```bash
emerge --ask --depclean
```
We need to update the system with the new USE flags
```bash
emerge --ask --verbose --update --deep --newuse @world
```
You will see that the USE attributes have changed to reflect which flags not to use.
Accept the installation and wait for eternity...
#### TIMEZONE AND LOCALES
After waiting an eternity, we are going to update the timezone and locales.
For example, to put the Madrid timezone, type
```bash
echo "Europe/Madrid" > /etc/timezone
emerge --config sys-libs/timezone-data
rm /etc/localtime
emerge --config sys-libs/timezone-data
```
Now, for the locale, edit the file `/etc/locale.gen` and uncomment your locale. Type
```bash
locale-gen
```
And the new locale will be installed on your system. Select the locale with
```bash
eselect locale list # To select the locales
eselect locale set X
```
Reload the environment with
```bash
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```
### KERNEL
We are using the normal gentoo kernel.
Install first the linux firmware, sof-firmware and (if you're using intel), intel microcode.
```bash
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-firmware/sof-firmware
emerge --ask sys-firmware/intel-microcode
```
Install the kernel by adding the USE flag dist-kernel and dracut and type
```bash
emerge --ask sys-kernel/gentoo-kernel
```
Clean up packages with
```bash
emerge --depclean
emerge --prune sys-kernel/gentoo-kernel sys-kernel/gentoo-kernel-bin
```
### CONFIGURING THE SYSTEM
#### FSTAB
Create the file `/etc/fstab` and add the following:
```bash
UUID=AAAA-BBBB  /efi  vfat  defaults,noatime,umask=0077  0  2
UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  none  swap  sw  0  0
UUID=yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy  /     ext4  defaults,noatime  0  1
```
To check UUIDs, type `blkid`
#### NETWORK
Set the hostname with:
```bash
echo <hostname> > /etc/hostname
```
We are going to set NetworkManager. First add the USE flags networkmanager, dbus, wifi, -iwd and -dhcpcd. (This is necessary to enable wireless WiFi)
Install the package with
```bash
emerge --ask net-misc/networkmanager
```
and enable the service to start at boot time
```bash
rc-update add NetworkManager default
```
Edit the /etc/hosts file and add this.
```bash
127.0.0.1     <host>.homenetwork <host> localhost
::1           <host>.homenetwork <host> localhost
```
#### SYSTEM INFORMATION
Set the root password and edit the file `/etc/rc.conf`.
To set the keymaps, edit the file `/etc/conf.d/keymaps`.
There's no need to edit the file `/etc/conf.d/hwClock`.
### SYSTEM TOOLS
#### LOGGER
```bash
emerge --ask app-admin/sysklogd
rc-update add sysklogd default
```
#### CRON
```bash
emerge --ask sys-process/cronie
rc-update add cronie default
```
#### FILE INDEXING
```bash
emerge --ask sys-apps/mlocate
```
#### SSH
```bash
rc-update add sshd default
```
#### BASH COMPLETION
```bash
emerge --ask app-shells/bash-completion
```
#### TIME SYNCHRONIZATION
```bash
emerge --ask net-misc/chrony
rc-update add chronyd default
```
#### FILESYSTEM AND DISKS
```bash
emerge --ask sys-fs/dosfstools
emerge --ask sys-block/io-scheduler-udev-rules
```
### BOOTLOADER
```bash
emerge --ask --verbose sys-boot/grub
```
Add the variable GRUB_PLATFORMS="efi-64" to `make.conf` file, and execute
```bash
emerge --ask sys-boot/grub
```
Install grub with
```
grub-install --efi-directory=/efi
```
and apply the configuration with
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```
## FIRST BOOT AND POST-CONFIGURATIONS
After completing the installation, exit the chroot and unmount remaining disks
```bash
exit
cd
umount -R /mnt/gentoo
reboot 
```
If everything went OK, you have installed Gentoo successfully.
### CLEANING OLD PORTAGE FILES
Portage by default preserves copies of downloaded files, on local storage: source tarballs in /var/cache/distfiles and binary packages in /var/cache/binhost/gentoo. If an update downloads a newer version of these files, the earlier versions are still preserved.
If we wanted to delete old versions and free up space:
```bash
emerge --ask app-portage/gentoolkit
# For cleaning old source tarballs
eclean-disk
# For cleaning old binpkgs
eclean-pkg
```
### ADDING A USER
```bash
useradd -m -G users,wheel,<othergroups...> -s /bin/bash spongebob
passwd spongebob
```
To allow that user to have root privileges, install the package `app-admin/sudo` and edit the sudoers file to allow access to wheel users.
Otherwise, use the su - command.
### CLEANING INSTALLATION FILES
```bash
rm /stage3-*.tar.*
```
## MANTEINANCE
Gentoo manteinance should be done every week/2 weeks.
To sync configured repos
```bash
emaint sync -a
```
Review the news (IMPORTANT), and execute the general update with
```bash
emerge --ask --verbose --update --deep --newuse @world
```
Check the updates (IMPORTANT), update and review new config files with
```bash
dispatch-conf
```
If Portage shows this output
```bash
Use emerge @preserved-rebuild
```
execute:
```bash
emerge --ask @preserved-rebuild
```
If the kernel was updated, verify its installation with
```bash
ls -lh /boot
```
reboot and verify you're using the new one with
```bash
uname -r
```
Clean old dependencies (use --pretend flag to check if anything is wrong), and if absolutely necessary, clean temporary compilation directories with
```bash
eclean-dist --pretend
eclean-dist
```
## CONCLUSIONS
Gentoo is a Linux distribution that advanced user can use and install if they want a challenge. You'll need a good pc, and lots, lots of patience.








