#!/bin/bash
set -eE
set -x

sudo apt install -y arch-install-scripts archlinux-keyring pacman-package-manager libarchive-tools systemd-container libalpm13t64 
# libalpm16
sudo pacman-key --init
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp  -a keyrings /usr/share/
sudo cp  etc/pacman.d/mirrorlist /etc/pacman.d
sudo cp etc/pacman.conf /etc
sudo sudo pacman-key --populate archlinuxarm
sudo pacman -Syyu

mkdir base_camp
sudo pacstrap ./base_camp base sudo arch-install-scripts archlinux-keyring
sudo cp pacstrap.sh lxdm-setup.sh firstboot-growroot.sh ./base_camp
sudo cp -a etc keyrings ./base_camp
sudo systemd-nspawn -D ./base_camp --resolv-conf=replace-host --as-pid2 /pacstrap.sh
