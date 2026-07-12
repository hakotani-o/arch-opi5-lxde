#!/bin/bash
set -eE

sudo pacman-key --init
#sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp  -a keyrings /usr/share/pacman
#sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
#sudo cp etc/pacman.conf /etc
sudo sudo pacman-key --populate archlinuxarm
sudo pacman -Syyu

sudo rm -rf ./mnt && sudo mkdir ./mnt
sudo pacstrap ./mnt base linux-aarch64 linux-firmware vim sudo 
sudo pacman -S --noconfirm --root ./mnt xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pulseaudio alsa-utils pavucontrol zenity cloud-guest-utils e2fsprogs gvfs udisks2 clapper mpv vulkan-tools mesa-utils
sudo ./lxdm-setup.sh
# pipewire-pulse
# キャッシュクリア
yes|sudo pacman -Scc --root ./mnt 
cd mnt && sudo bsdtar -zcf /Arch-linux.rootfs.tar.gz --xattrs ./*
cd ..
