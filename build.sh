#!/bin/bash

# Script taken from RenderBroken and modified to be more automated.

# Kernel Details
VER=CM-Mod

# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=Yoinx
export KBUILD_BUILD_HOST=localhost
export CCACHE=ccache

build=zips
kernel="CM-Mod"

##### Main Toolchain
toolchain=/media/joe/linux_storage/toolchains/linaro-4.9/bin
#####

toolchain2="arm-eabi-"
kerneltype="zImage"
jobcount="-j5"
base=0x00000000
pagesize=2048
ramdisk_offset=0x05000000
tags_offset=0x04800000
CURRENTDATE=$(date +"%m-%d")
variant="vs980"
config="vs980_defconfig"
cmdline="console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0"
rom="LP"
ramdisk=ramdisk

# Make required directories if they don't exist.
mkdir -p zips
mkdir -p out
mkdir -p ozip


# Begin commands
rm -rf out/g2/*
			export ARCH=arm
			export CROSS_COMPILE=$toolchain/"$toolchain2"
			rm -rf ozip/boot.img
			rm -rf ozip/system/lib/modules
			rm -rf arch/arm/boot/"$kerneltype"
			mkdir -p ozip/system/lib/modules
			make clean && make mrproper
			echo "Working directory cleaned...";;

			make "$config"
			make "$jobcount"
			exit 0;;

if [ -f arch/arm/boot/"$kerneltype" ]; then
	cp arch/arm/boot/"$kerneltype" out/g2
	rm -rf ozip/system/modules/*
	mkdir -p ozip/system/lib/modules
	find . -name "*.ko" -exec cp {} ozip/system/lib/modules \;
else
	echo "Nothing has been made..."
			export ARCH=arm
			export CROSS_COMPILE=$toolchain/"$toolchain2"
			rm -rf ozip/boot.img
			rm -rf ozip/system/lib/modules
			rm -rf arch/arm/boot/"$kerneltype"
			mkdir -p ozip/system/lib/modules
			make clean && make mrproper
			echo "Working directory cleaned...";;
			make "$config"
			make "$jobcount" CONFIG_DEBUG_SECTION_MISMATCH=y
			exit 0;;
fi

	echo "Creating AOSP Ramdisk..."
	./mkbootfs $ramdisk | gzip > out/g2/ramdisk.gz
	ramdisk=out/g2/ramdisk.gz


echo "Making DT.img..."
if [ -f arch/arm/boot/$kerneltype ]; then
	./dtbTool -s 2048 -o out/g2/dt.img arch/arm/boot/
else
	echo "No build found..."
	exit 0;
fi

echo "Making boot.img..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	./mkbootimg --kernel /out/g2/"$kerneltype" --ramdisk $ramdisk --cmdline "$cmdline" --base $base --pagesize $pagesize --offset $ramdisk_offset --tags-addr $tags_offset --dt out/g2/dt.img -o ozip/boot.img
else
	echo "No build found..."
	exit 0;
fi

echo "Kernel Bump Boot.img..."
sh kernel_bump.sh
mv ozip/boot_bumped.img ozip/boot.img
echo "Kernel BUMP done!";

echo "Zipping..."
cd ozip
zip -r ../"$kernel"-"$rom"_"$variant"-bumped.zip .
mv ../"$kernel"-"$rom"_"$variant"-bumped.zip $build
cd ..
rm -rf /out/g2/*
echo "Done..."
