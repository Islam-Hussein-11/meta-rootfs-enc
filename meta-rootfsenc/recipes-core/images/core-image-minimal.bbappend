

IMAGE_INSTALL += "${@bb.utils.contains('DISTRO_FEATURES', 'enc-rootfs', 'mount-bootimage', '', d)}"


separate_boot() {
       [ -d "${WORKDIR}/boot" ] && rm -rf "${WORKDIR}/boot"
       mv ${WORKDIR}/rootfs/boot ${WORKDIR}
}

create_boot_image() {
       local BOOT_IMAGE_SIZE="65536" #Should be a variable defined somewhere else
       #Also check if $ROOTFS_SIZE changes when we encrypt
       local BOOT_IMAGE_PATH="${IMGDEPLOYDIR}/boot-image-${MACHINE}${IMAGE_VERSION_SUFFIX}${IMAGE_NAME_SUFFIX}.${IMAGE_TEGRAFLASH_FS_TYPE}"
       local BOOT_LINK_PATH="${IMGDEPLOYDIR}/boot-image-${MACHINE}${IMAGE_NAME_SUFFIX}.${IMAGE_TEGRAFLASH_FS_TYPE}"
       # If generating an empty image the size of the sparse block should be large
       # enough to allocate an ext4 filesystem using 4096 bytes per inode, this is
       # about 60K, so dd needs a minimum count of 60, with bs=1024 (bytes per IO)

       eval local COUNT=\"0\"
       eval local MIN_COUNT=\"60\"
       if [ $BOOT_IMAGE_SIZE -lt $MIN_COUNT ]; then
               eval COUNT=\"$MIN_COUNT\"
       fi
       # Create a sparse image block
       dd if=/dev/zero of=$BOOT_IMAGE_PATH  seek=$BOOT_IMAGE_SIZE  count=$COUNT bs=1024
       mkfs.ext4 -F -i 4096 -b 4096 -O ^metadata_csum_seed  $BOOT_IMAGE_PATH  -d ${WORKDIR}/boot
       # Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
       fsck.ext4 -pvfD $BOOT_IMAGE_PATH  || [ $? -le 3 ]

       ln -rsf $BOOT_IMAGE_PATH $BOOT_LINK_PATH
}


tegraflash_custom_pre:jetson-xavier-nx-devkit-emmc() {
       case "${DISTRO_FEATURES}" in
        *enc-rootfs*)
                local BOOT_LINK_PATH="${IMGDEPLOYDIR}/boot-image-${MACHINE}${IMAGE_NAME_SUFFIX}.${IMAGE_TEGRAFLASH_FS_TYPE}"
                cp $BOOT_LINK_PATH ./boot-image.${IMAGE_TEGRAFLASH_FS_TYPE}
               ;;
       esac
}



#################################################################################################################
do_image[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'enc-rootfs', 'e2fsprogs-native:do_populate_sysroot', '', d)}"
do_image[depends] += "${@bb.utils.contains('DISTRO_FEATURES', 'enc-rootfs', 'coreutils-native:do_populate_sysroot', '', d)}"

IMAGE_PREPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'enc-rootfs', 'separate_boot; ', '', d)}"
IMAGE_PREPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'enc-rootfs', 'create_boot_image; ', '', d)}"
################################################################################################################
