#!/bin/bash

###############################################################################
# To all DEV around the world :)                                              #
# to build this kernel you need to be ROOT and to have bash as script loader  #
# do this:                                                                    #
# cd /bin                                                                     #
# rm -f sh                                                                    #
# ln -s bash sh                                                               #
#                                                                             #
# Now you can build my kernel.                                                #
# using bash will make your life easy. so it's best that way.                 #
# Have fun and update me if something nice can be added to my source.	      #
#                                                         		      #
# Original scripts by halaszk & various sources throughout gitHub             #
# modified by UpInTheAir for SkyHigh kernels				      #
# very very slightly modified by The Sickness for his Twisted S6 kernel       #
#                                                         		      #
###############################################################################


############################################ SETUP ############################################

# Time of build startup
res1=$(date +%s.%N)
#################################### OPTIONAL SOURCE CLEAN ####################################
echo
echo "${bldcya}***** Setting up Environment *****${txtrst}";
echo
. ./env_setup.sh ${1} || exit 1;

if [ ! -f $KERNELDIR/.config ]; then
	echo
	echo "${bldcya}***** Writing Config *****${txtrst}";
	cp $KERNELDIR/arch/arm64/configs/$KERNEL_CONFIG .config;
	make ARCH=arm64 $KERNEL_CONFIG;
fi;

. $KERNELDIR/.config


########################################### CLEAN UP ##########################################

echo
echo "${bldcya}***** Clean up first *****${txtrst}"

find . -type f -name "*~" -exec rm -f {} \;
find . -type f -name "*orig" -exec rm -f {} \;
find . -type f -name "*rej" -exec rm -f {} \;

if [ -e $BK/$TARGET/boot.img ]; then
	rm -rf $BK/$TARGET/boot.img
fi;
if [ -e $BK/$TARGET/Image ]; then
	rm -rf $BK/$TARGET/Image
fi;

echo "Done"

####################################### COMPILE IMAGES #######################################
cd ${KERNELDIR}
echo
echo "${bldcya}***** Compiling kernel *****${txtrst}"

if [ $USER != "root" ]; then
	make CONFIG_DEBUG_SECTION_MISMATCH=y -j8 Image ARCH=arm64
else
	make -j8 Image ARCH=arm64
fi;

if [ -e $KERNELDIR/arch/arm64/boot/Image ]; then
	echo
	echo "${bldcya}***** Final Touch for Kernel *****${txtrst}"
	stat $KERNELDIR/arch/arm64/boot/Image || exit 1;
	mv ./arch/arm64/boot/Image ./$BK/$TARGET
	echo
else
	echo "${bldred}Kernel STUCK in BUILD!${txtrst}"
	exit 0;
fi;

echo
echo "Done"

############ BOOT.IMG GENERATION #####################################

echo
echo "${bldcya}***** Make boot.img *****${txtrst}"
echo
cd ${KERNELDIR}/$BK
./mkbootimg --kernel ./$TARGET/Image --dt ./$TARGET/dt.img --ramdisk ./$TARGET/ramdisk.gz --base 0x10000000 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --pagesize 2048 -o ./$TARGET/boot.img

echo -n "SEANDROIDENFORCE" >> ./$TARGET/boot.img

echo "Done"

#################################### OPTIONAL SOURCE CLEAN ####################################

echo
echo "${bldcya}***** Clean source *****${txtrst}"

cd ${KERNELDIR}
read -p "Do you want to Clean the source? (y/n) > " mc
if [ "$mc" = "Y" -o "$mc" = "y" ]; then
	xterm -e make clean
	xterm -e make mrproper
fi

echo
echo "Build completed"
echo
echo "${txtbld}***** Flashable zip found in output directory *****${txtrst}"
echo
# build script ends
