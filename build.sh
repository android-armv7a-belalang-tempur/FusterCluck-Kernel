#!/bin/bash

# Script taken from RenderBroken and modified to be more automated.

# Kernel Details

# Get current build number
if [ ! -f build_number.txt ]; then 
old_build_num=0
else
old_build_num=$(head -1 build_number.txt)
fi
build_num=$((old_build_num + 1))
# Overwrite build_number.txt for next time
echo $build_num > build_number.txt

# Get Date tag builds
DATE=`date +%Y-%m-%d`

VER=Alpha-Build_$build_num-$DATE


# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=Yoinx
export KBUILD_BUILD_HOST=localhost
export CCACHE=ccache

build=zips/
kernel="Yoinx"

##### Main Toolchain
toolchain=toolchains/sabermod-4.9/bin
#####

toolchain2="arm-eabi-"
kerneltype="zImage"
jobcount="-j5"
base=0x00000000
pagesize=2048
ramdisk_offset=0x05000000
tags_offset=0x04800000
variant="vs980"
config="vs980_defconfig"
cmdline="console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0 androidboot.selinux=permissive"
rom="LP_5.1"
ramdisk=ramdisk/

# Make required directories if they don't exist.
mkdir -p zips
mkdir -p out/g2
mkdir -p ozip


# Begin commands
# rm -rf out/g2/*
			export ARCH=arm
			export CROSS_COMPILE=$toolchain/"$toolchain2"
			rm -rf ozip/boot.img
			rm -rf ozip/system/lib/modules
			rm -rf arch/arm/boot/"$kerneltype"
			mkdir -p ozip/system/lib/modules
#			make clean && make mrproper
#			echo "Working directory cleaned..."
			make "$config"
			make "$jobcount" CONFIG_DEBUG_SECTION_MISMATCH=y

	echo "Creating AOSP Ramdisk..."
	./mkbootfs $ramdisk | gzip > out/g2/ramdisk.gz
	ramdisk=out/g2/ramdisk.gz
cp arch/arm/boot/$kerneltype out/g2/$kerneltype

# Create the required dtb files. 
# The names *WILL* vary if building for a device other than the VS980
./scripts/dtc/dtc -I dts -O dtb -o out/g2/msm8974-g2-vzw.dtb arch/arm/boot/dts/lge/msm8974-g2/msm8974-g2-vzw/msm8974-g2-vzw.dts
./scripts/dtc/dtc -I dts -O dtb -o out/g2/msm8974-v2-2-g2-vzw.dtb arch/arm/boot/dts/lge/msm8974-g2/msm8974-g2-vzw/msm8974-v2-2-g2-vzw.dts
./scripts/dtc/dtc -I dts -O dtb -o out/g2/msm8974-v2-g2-vzw.dtb arch/arm/boot/dts/lge/msm8974-g2/msm8974-g2-vzw/msm8974-v2-g2-vzw.dts


echo "Making DT.img..."
if [ -f arch/arm/boot/$kerneltype ]; then
	./dtbTool -s 2048 -o out/g2/dt.img out/g2/
	cp arch/arm/boot/$kerneltype out/g2/$kerneltype
else
	echo "No build found..."
	exit 0;
fi

echo "Making boot.img..."
if [ -f out/g2/"$kerneltype" ]; then
	./mkbootimg --kernel out/g2/"$kerneltype" --ramdisk $ramdisk --cmdline "$cmdline" --base $base --pagesize $pagesize --offset $ramdisk_offset --tags-addr $tags_offset --dt out/g2/dt.img -o ozip/boot.img
else
	echo "No build found..."
	exit 0;
fi

echo "Kernel Bump Boot.img..."
sh kernel_bump.sh
mv ozip/boot_bumped.img ozip/boot.img
echo "Kernel BUMP done!";

echo "Zipping..."
cp -r zip_script/. ozip/
cd ozip
zip -r "$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip .
mv "$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip ../$build
cd ..
rm -rf /out/g2/*
echo "Done..."
