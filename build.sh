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

# Get Date tag builds
DATE=`date +%Y-%m-%d`

VER=FusterCluck-R2-Build_$build_num-$DATE


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

# Move FusterCluck script into the ramdisks
cp ramdisks/common/FusterCluck_post_boot.sh ramdisks/non-stock/sbin/FusterCluck_post_boot.sh
cp ramdisks/common/FusterCluck_post_boot.sh ramdisks/stock/sbin/FusterCluck_post_boot.sh

function start_build () {


if [ $1 = stock ]; then
# Checkout stock files for bluetooth, these have been modified for CM
git checkout d85ca4f17461a00d4898ee2e4c1e130474621ee7 drivers/bluetooth/bluesleep.c
git checkout d85ca4f17461a00d4898ee2e4c1e130474621ee7 arch/arm/mach-msm/lge/8974-g2/board-8974-g2-rfkill.c
fi

case $1 in 
cm)
ramdisk=ramdisks/non-stock/
;;
stock)
ramdisk=ramdisks/stock/
;;
*)
esac

# Make required directories if they don't exist.
mkdir -p zips
mkdir -p out/g2
mkdir -p ozip


# Begin commands
			if [ "$2" = "dirty" ]; then
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

	echo "Creating Ramdisk..."
	./mkbootfs $ramdisk | gzip > out/g2/ramdisk.gz
	ramdisk=out/g2/ramdisk.gz

cp arch/arm/boot/$kerneltype out/g2/$kerneltype
# Make sure we grab our modules.
mkdir -p ozip/system/lib/modules
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
	tput setaf 1; echo "BUILD FAILED!"; tput sgr 0
	exit 0;
fi

echo "Making boot.img..."
if [ -f out/g2/"$kerneltype" ]; then
	./mkbootimg --kernel out/g2/"$kerneltype" --ramdisk $ramdisk --cmdline "$cmdline" --base $base --pagesize $pagesize --offset $ramdisk_offset --tags-addr $tags_offset --dt out/g2/dt.img -o ozip/boot.img
else
	tput setaf 1; echo "BUILD FAILED!"; tput sgr 0
	exit 0;

fi

echo "Kernel Bump Boot.img..."
sh kernel_bump.sh
mv ozip/boot_bumped.img ozip/boot.img
echo "Kernel BUMP done!";

echo "Zipping..."
cp -r zip_script/. ozip/
cd ozip
zip -r "$1"-"$rom"_"$variant"-"$VER"-bumped.zip .
mv "$1"-"$rom"_"$variant"-"$VER"-bumped.zip ../$build
cd ..
rm -rf /ozip/*
rm -rf out/g2/*

# Reset these files to the current HEAD at the end of a stock build.
if [ $1 = "stock" ]; then
git checkout HEAD drivers/bluetooth/bluesleep.c
git checkout HEAD arch/arm/mach-msm/lge/8974-g2/board-8974-g2-rfkill.c
fi

# Call function again from here to build stock
# this should prevent a second build for stock if the first build for cm failed.
if [ $1 = "cm" ]; then
start_build stock
fi

} # end of build function 

# Start the magic!
# allow for the possibility of dirty building by passing $1
start_build cm $1

# Remove the FusterCluck script so as to not make git think it needs to be commitedin the new location
rm ramdisks/non-stock/sbin/FusterCluck_post_boot.sh
rm ramdisks/stock/sbin/FusterCluck_post_boot.sh


# Do some checking to see if everything was successfull or not.
# Allow for the possibility that one build may succeed while the other fails.

echo " "
if [ -f zips/cm-"$rom"_"$variant"-"$VER"-bumped.zip ] || [ -f zips/stock-"$rom"_"$variant"-"$VER"-bumped.zip ]; then
	if [ -f zips/cm-"$rom"_"$variant"-"$VER"-bumped.zip ]; then 
		tput setaf 2; echo "Finished Building zips/cm-"$rom"_"$variant"-"$VER"-bumped.zip"; tput sgr 0
	else 
		tput setaf 1; echo "CM BUILD FAILED!"; tput sgr 0
	fi
	if [ -f zips/stock-"$rom"_"$variant"-"$VER"-bumped.zip ]; then 
		tput setaf 2; echo "Finished Building zips/stock-"$rom"_"$variant"-"$VER"-bumped.zip"; tput sgr 0
	else 
		tput setaf 1; echo "STOCK BUILD FAILED!"; tput sgr 0
	fi

	# Overwrite build_number.txt after successfull builds for next time
	echo $build_num > build_number.txt

else
tput setaf 1; echo "BUILD FAILED!"; tput sgr 0
fi 
echo "Done..." 
