#!/bin/bash

source shared.sh

EXTERNAL_REL_BUILDROOT=../buildroot_external

if [ ! -e buildroot/.config ]
then
	echo "MISSING BUILDROOT CONFIGURATION FILE"

	if [ -e ${RPI4_SENSORS_DEFCONFIG} ]
	then
		echo "USING ${RPI4_SENSORS_DEFCONFIG}"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${RPI4_SENSORS_DEFCONFIG_REL_BUILDROOT}
	else
		echo "Run ./save-buildroot-config.sh to save this as the default configuration in ${RPI4_SENSORS_DEFCONFIG}"
		echo "Then add packages as needed to complete the installation, re-running ./save_config.sh as needed"
		make -C buildroot defconfig BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} BR2_DEFCONFIG=${RPI4_DEFCONFIG}
	fi
else
	echo "USING EXISTING BUILDROOT CONFIG"
	echo "To force update, delete .config or make changes using make menuconfig and build again."
	make -C buildroot BR2_EXTERNAL=${EXTERNAL_REL_BUILDROOT} -j5
fi
