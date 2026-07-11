#!/bin/bash
set -eE

sudo apt install arch-install-scripts archlinux-keyring libalpm13t64 pacman-package-manager libarchive-tools
sudo pacman-key --init
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp  -a keyrings /usr/share/
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp etc/pacman.conf /etc
sudo sudo pacman-key --populate archlinuxarm
sudo pacman -Syyu

mkdir mnt
#sudo pacstrap ./mnt  base vim base-devel sudo linux-aarch64 linux-firmware xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pulseaudio alsa-utils pavucontrol zenity  cloud-guest-utils e2fsprogs gvfs udisks2 gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-bad clapper mpv vulkan-tools mesa-utils
sudo pacstrap ./mnt linux-aarch64 linux-firmware base vim sudo xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pipewire-pulse alsa-utils pavucontrol zenity cloud-guest-utils e2fsprogs gvfs udisks2 clapper mpv vulkan-tools mesa-utils
# キャッシュクリア
sudo pacman -Scc --root ./mnt --noconfirm
