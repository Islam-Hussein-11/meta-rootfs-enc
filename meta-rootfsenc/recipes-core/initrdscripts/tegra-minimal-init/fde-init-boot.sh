#!/bin/sh

set -x

PATH=/sbin:/bin:/usr/sbin:/usr/bin
mount -t proc proc -o nosuid,nodev,noexec /proc
mount -t devtmpfs none -o nosuid /dev
mount -t sysfs sysfs -o nosuid,nodev,noexec /sys
mount -t efivarfs efivarfs -o nosuid,nodev,noexec /sys/firmware/efi/efivars

rootdev=""
opt="rw"
wait=""
fstype="auto"

[ ! -f /etc/platform-preboot ] || . /etc/platform-preboot

if [ -z "$rootdev" ]; then
    for bootarg in `cat /proc/cmdline`; do
	case "$bootarg" in
	    root=*) rootdev="${bootarg##root=}" ;;
	    ro) opt="ro" ;;
	    rootwait) wait="yes" ;;
        rootfstype=*) fstype="${bootarg##rootfstype=}" ;;
	esac
    done
fi

if [ -n "$wait" -a ! -b "${rootdev}" ]; then
    echo "Waiting for ${rootdev}..."
    count=0
    while [ $count -lt 25 ]; do
	test -b "${rootdev}" && break
	sleep 0.1
	count=`expr $count + 1`
    done
fi

echo "Mounting ${rootdev}..."


[ -d /mnt ] || mkdir -p /mnt
count=0
while [ $count -lt 5 ]; do
    __l4t_enc_root_dm="l4t_enc_root";
    __l4t_enc_root_dm_dev="/dev/mapper/${__l4t_enc_root_dm}"
    eval nvluks-srv-app -g -c "12345678-1234-1234-1234-123456789abc" | cryptsetup luksOpen /dev/mmcblk0p2 ${__l4t_enc_root_dm}  
    if mount "${__l4t_enc_root_dm_dev}" /mnt; then
	break
    fi
    sleep 1.0
done


# Disable luks-srv TA
nvluks-srv-app -n > /dev/null 2>&1;

[ $count -lt 5 ] || exec sh

[ ! -f /etc/platform-pre-switchroot ] || . /etc/platform-pre-switchroot

echo "Switching to rootfs on ${rootdev}..."
mount --move /sys  /mnt/sys
mount --move /proc /mnt/proc
mount --move /dev  /mnt/dev
exec switch_root /mnt /sbin/init
