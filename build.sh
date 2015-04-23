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

VER=FusterCluck-R1-Build_$build_num-$DATE


# Vars
export LOCALVERSION=~`echo $VER`
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=Yoinx
export KBUILD_BUILD_HOST=localhost
export CCACHE=ccache

build=zips/
kernel="FusterCluck"

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
ramdiskcm=ramdisks/non-stock/
ramdiskstock=ramdisks/stock/

# Make required directories if they don't exist.
mkdir -p zips
mkdir -p out/g2
mkdir -p ozip



# Begin commands
			if [ "$1" = "dirty" ]; then
			echo "Building Dirty"
			else
			rm -rf out/g2/*
 			make clean && make mrproper
 			rm -rf ozip/boot.img
			rm -rf ozip/system/lib/modules
			rm -rf arch/arm/boot/"$kerneltype"
			echo "Working directory cleaned..."
			fi
			export ARCH=arm
			export CROSS_COMPILE=$toolchain/"$toolchain2"
			mkdir -p ozip/system/lib/modules
			make "$config"
			make "$jobcount" CONFIG_DEBUG_SECTION_MISMATCH=y

	echo "Creating AOSP Ramdisk..."
	./mkbootfs $ramdiskcm | gzip > out/g2/ramdiskcm.gz
	ramdiskcm=out/g2/ramdiskcm.gz
	echo "Creating Stock Ramdisk..."
	./mkbootfs $ramdiskstock | gzip > out/g2/ramdiskstock.gz
	ramdiskstock=out/g2/ramdiskstock.gz
	
cp arch/arm/boot/$kerneltype out/g2/$kerneltype
# Make sure we grab our modules.
mdir -p ozip/system/lib/modules
find . -name "*.ko" -exec cp {} ozip/system/lib/modules \;

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



echo "Making cm/aosp boot.img..."
if [ -f out/g2/"$kerneltype" ]; then
	./mkbootimg --kernel out/g2/"$kerneltype" --ramdisk $ramdiskcm --cmdline "$cmdline" --base $base --pagesize $pagesize --offset $ramdisk_offset --tags-addr $tags_offset --dt out/g2/dt.img -o ozip/boot.img
else
	echo "No build found..."
	exit 0;
fi

echo "Kernel Bump CM Boot.img..."
sh kernel_bump.sh
mv ozip/boot_bumped.img ozip/boot.img
echo "Kernel BUMP done!";

echo "Zipping..."
cp -r zip_script/. ozip/
cd ozip
zip -r cm-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip .
mv cm-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip ../$build
cd ..
rm -rf /ozip/*

echo "Making stock boot.img..."
if [ -f out/g2/"$kerneltype" ]; then
	./mkbootimg --kernel out/g2/"$kerneltype" --ramdisk $ramdiskstock --cmdline "$cmdline" --base $base --pagesize $pagesize --offset $ramdisk_offset --tags-addr $tags_offset --dt out/g2/dt.img -o ozip/boot.img
else
	echo "No build found..."
	exit 0;
fi

echo "Kernel Bump Stock Boot.img..."
sh kernel_bump.sh
mv ozip/boot_bumped.img ozip/boot.img
echo "Kernel BUMP done!";

echo "Zipping..."
cp -r zip_script/. ozip/
cd ozip
zip -r stock-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip .
mv stock-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip ../$build
cd ..
rm -rf ozip/*
rm -rf out/g2/*

echo " "
if [ -f zips/cm-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip ]; then 
tput setaf 2; echo "Finished Building cm-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip"; tput sgr 0
else 
tput setaf 1; echo "CM BUILD FAILED!"; tput sgr 0
fi
if [ -f zips/stock-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip ]; then 
tput setaf 2; echo "Finished Building stock-"$kernel"-"$rom"_"$variant"-"$VER"-bumped.zip"; tput sgr 0
else 
tput setaf 1; echo "STOCK BUILD FAILED!"; tput sgr 0
fi
echo "Done..." 
