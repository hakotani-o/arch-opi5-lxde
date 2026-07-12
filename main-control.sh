#!/bin/bash
set -eE

	sudo rm -rf ./mnt Arch-linux-aarch64-orangepi-5-*.img base_camp
	./das-u-boot.sh orangepi-5-rk3588s_defconfig
	./base_camp.sh
	sudo ./disk_image.sh orangepi-5 rk3588s-orangepi-5
	./das-u-boot.sh orangepi-5-plus-rk3588_defconfig
	sudo ./disk_image.sh orangepi-5-plus rk3588-orangepi-5-plus
