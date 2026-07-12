#!/bin/bash
set -eE

sudo apt install arch-install-scripts archlinux-keyring pacman-package-manager libarchive-tools libalpm13t64
sudo pacman-key --init
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp  -a keyrings /usr/share/
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp etc/pacman.conf /etc
sudo sudo pacman-key --populate archlinuxarm
sudo pacman -Syyu

mkdir mnt
#sudo pacstrap ./mnt  base vim base-devel sudo linux-aarch64 linux-firmware xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pulseaudio alsa-utils pavucontrol zenity  cloud-guest-utils e2fsprogs gvfs udisks2 clapper mpv vulkan-tools mesa-utils
#sudo pacstrap ./mnt base base-devel linux-aarch64 linux-firmware base vim sudo xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pulseaudio alsa-utils pavucontrol zenity cloud-guest-utils e2fsprogs gvfs udisks2 clapper mpv vulkan-tools mesa-utils
# pipewire-pulse
sudo pacstrap ./mnt base linux-aarch64 linux-firmware vim sudo
sudo pacman -S --noconfirm --root ./mnt xorg lxde networkmanager network-manager-applet ttf-dejavu noto-fonts-cjk pulseaudio alsa-utils pavucontrol zenity cloud-guest-utils e2fsprogs gvfs udisks2 clapper mpv vulkan-tools mesa-utils
# キャッシュクリア
yes|sudo pacman -Scc --root ./mnt
