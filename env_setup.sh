#!/bin/bash

# Colorize and add text parameters
export red=$(tput setaf 1)             #  red
export grn=$(tput setaf 2)             #  green
export blu=$(tput setaf 4)             #  blue
export cya=$(tput setaf 6)             #  cyan
export txtbld=$(tput bold)             #  Bold
export bldred=${txtbld}$(tput setaf 1) #  red
export bldgrn=${txtbld}$(tput setaf 2) #  green
export bldblu=${txtbld}$(tput setaf 4) #  blue
export bldcya=${txtbld}$(tput setaf 6) #  cyan
export txtrst=$(tput sgr0)             #  Reset


# check if ccache installed, if not install
if [ ! -e /usr/bin/ccache ]; then
	echo "You must install 'ccache' to continue.";
	sudo apt-get install ccache
fi

# check if xmllint installed, if not install
if [ ! -e /usr/bin/xmllint ]; then
	echo "You must install 'xmllint' to continue.";
	sudo apt-get install libxml2-utils
fi

echo "${bldcya}***** Clean up Environment before compile *****${txtrst}";


# Make clean source
read -t 5 -p "Make clean source, 5sec timeout (y/n)?";
if [ "$REPLY" == "y" ]; then
make distclean;
make mrproper;
fi;

# clear ccache
read -t 5 -p "Clear ccache but keeping the config file, 5sec timeout (y/n)?";
if [ "$REPLY" == "y" ]; then
ccache -C;
fi;


TARGET='G920P'
echo
echo "Starting your build for $TARGET"

# location
export KERNELDIR=`readlink -f .`;


# set build variables
BK=build_kernel
export KCONFIG_NOTIMESTAMP=true
export ARCH=arm64;
export SUB_ARCH=arm64;

export KERNEL_CONFIG="zerofltespr_02_defconfig";

# build script
export USER=`whoami`;
export TMPFILE=`mktemp -t`;


# system compiler
export CROSS_COMPILE=/home/jeton/Downloads/kernel/toolchain/android-ndk-r11c/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/aarch64-linux-android-

# CPU Core
export NUMBEROFCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;
