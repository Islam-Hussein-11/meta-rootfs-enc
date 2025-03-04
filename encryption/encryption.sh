#!/bin/bash
set -x


__rootfs_name="core-image-minimal.ext4"
__enc_rootfs_mountpoint="mnt_enc_rootfs"
__eks_img="tools/eks_t194.img"
__l4t_enc="l4t_enc_rootfs"
__data_enc="data_enc"
__rootfs_original_mountpoint="mnt_original_rootfs"
__rootfsuuid="12345678-1234-1234-1234-123456789abc"
__original_rootfs="../build/tmp/deploy/images/jetson-xavier-nx-devkit-emmc/core-image-minimal-jetson-xavier-nx-devkit-emmc.rootfs.ext4"
__temp_dir="../build/tmp/deploy/images/jetson-xavier-nx-devkit-emmc/temp"
__deploy_dir="../build/tmp/deploy/images/jetson-xavier-nx-devkit-emmc"
__tegraflash_enc_name="core-image-minimal-jetson-xavier-nx-devkit-emmc.rootfs-ecnrypted.tegraflash.tar.gz"
__tegraflash_name="core-image-minimal-jetson-xavier-nx-devkit-emmc.rootfs.tegraflash.tar.gz"
GEN_LUKS_PASS_CMD="tools/gen_luks_passphrase.py"
genpass_opt=""
genpass_opt+=" -k tools/ekb.key "
genpass_opt+=" -g "
genpass_opt+=" -c '${__rootfsuuid}' "

GEN_LUKS_PASS_CMD+=" ${genpass_opt}"

if [ -f "${__rootfs_name}" ]; then
    echo "File already Exists, deleting it!"
    rm ${__rootfs_name}
else
    echo "File doesn't exist Making New one"
fi

mkdir -p ${__rootfs_original_mountpoint} ${__enc_rootfs_mountpoint}

truncate -s 14612955136 ${__rootfs_name}

eval ${GEN_LUKS_PASS_CMD} | sudo cryptsetup \
		--type luks2 \
		-c aes-xts-plain64 \
		-s 256 \
		--uuid "${__rootfsuuid}" \
		luksFormat \
        ${__rootfs_name}

eval ${GEN_LUKS_PASS_CMD} | sudo cryptsetup luksOpen ${__rootfs_name} ${__l4t_enc}
sudo mkfs.ext4 /dev/mapper/${__l4t_enc}





sudo mount /dev/mapper/${__l4t_enc} ${__enc_rootfs_mountpoint}
sudo mount  ${__original_rootfs} ${__rootfs_original_mountpoint}

sudo tar -cf - -C ${__rootfs_original_mountpoint} . | sudo tar -xpf - -C ${__enc_rootfs_mountpoint}
sleep 5
sudo umount ${__enc_rootfs_mountpoint}
sudo cryptsetup luksClose ${__l4t_enc}
sudo umount ${__rootfs_original_mountpoint}


if [ -f /dev/mapper/${__l4t_enc} ]; then
    sudo cryptsetup luksClose ${__l4t_enc}
fi

if [ -d "${__temp_dir}" ]; then
    echo "Temp directoy Exists deleting it!"
    sudo rm -rf ${__temp_dir}
    mkdir -p ${__temp_dir}
else
    mkdir -p ${__temp_dir}
fi

pushd ${__temp_dir}
tar -xvf ../${__tegraflash_name} -C .
popd

cp ${__rootfs_name} ${__temp_dir}
cp ${__eks_img} ${__temp_dir}/eks.img

if [ -f ${__deploy_dir}/${__tegraflash_enc_name} ]; then
    echo "Tegraflash encrypted found from previous build.. removing it!"
    rm ${__deploy_dir}/${__tegraflash_enc_name}
fi


rm ${__rootfs_name}
tar --sparse --numeric-owner --transform="s,^\./,," -C "${__temp_dir}" -cf- . | pigz -9 -n --fast --rsyncable > ${__deploy_dir}/${__tegraflash_enc_name}
