# Writing ISO image to USB
## Windows
The most common program is Rufus. It is a GUI program that lets you select the partition type and the writing mode (DD or ISO).
## Linux and MacOS
The most common program is `dd`. To write safely an ISO to USB, type
```bash
dd if=./iso-image.iso of=/dev/XXX status=progress bs=4m
```
> [!warning] WARNING
> The USB must be unmounted previously!