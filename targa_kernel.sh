#!/bin/bash
set -m

# Build script for JBX-Kernel RELEASE
echo "Cleaning out kernel source directory..."
echo " "
cd ~/jbx
make mrproper
make ARCH=arm distclean

# We build the kernel and its modules first
# Launch execute script in background
# First get tags in shell
echo "Cleaning out Android source directory..."
echo " "
cd ~/mokee
export USE_CCACHE=1
source build/envsetup.sh
add_lunch_combo mk_targa-userdebug
lunch mk_targa-userdebug

# built kernel & modules
echo "Building kernel and modules..."
echo " "

export LOCALVERSION="-qqzwc"
make -j4 TARGET_BOOTLOADER_BOARD_NAME=targa TARGET_KERNEL_SOURCE=/home/winzone/jbx/ TARGET_KERNEL_CONFIG=mapphone_targa_defconfig BOARD_KERNEL_CMDLINE='root=/dev/ram0 rw mem=1023M@0x80000000 console=null vram=10300K omapfb.vram=0:8256K,1:4K,2:2040K init=/init ip=off mmcparts=mmcblk1:p7(pds),p15(boot),p16(recovery),p17(cdrom),p18(misc),p19(cid),p20(kpanic),p21(system),p22(cache),p23(preinstall),p24(webtop),p25(userdata),p26(emstorage) mot_sst=1 androidboot.bootloader=0x0A72 androidboot.selinux=permissive' $OUT/boot.img

# We don't use the kernel but the modules
echo "Copying modules to package folder"
echo " "
cp -r /mokee/out/target/product/targa/system/lib/modules/* ~/workspace/system/lib/modules/
cp /mokee/out/target/product/targa/kernel ~/workspace/system/etc/kexec/

echo "------------- "
echo "Done building"
echo "------------- "
echo " "

# Copy and rename the zImage into nightly/nightly package folder
# Keep in mind that we assume that the modules were already built and are in place
# So we just copy and rename, then pack to zip including the date
echo "Packaging flashable Zip file..."
echo " "

cd ~/workspace
zip -r "JBX-Kernel-1.4-Hybrid-Edison-4.3_$(date +"%Y-%m-%d").zip" *
mv "JBX-Kernel-1.4-Hybrid-Edison-4.3_$(date +"%Y-%m-%d").zip" $OUT

echo "Done!"
