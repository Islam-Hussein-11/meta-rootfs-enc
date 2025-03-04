DESCRIPTION = "Systemd mount target to mount boot filesystem on /boot"
#TODO: Decide on licensing
LICENSE = "CLOSED"
#LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

SRC_URI = "file://boot.mount"
DEPENDS = "systemd"
S = "${WORKDIR}"

do_compile[no_exec] = "1"

do_install() {
        install -d ${D}${base_libdir}/systemd
        install -d ${D}${base_libdir}/systemd/system
        install -d ${D}${base_libdir}/systemd/system/local-fs.target.wants
        install -m 0644 boot.mount ${D}${base_libdir}/systemd/system
        ln -rs ${D}${base_libdir}/systemd/system/boot.mount ${D}${base_libdir}/systemd/system/local-fs.target.wants/boot.mount
}

FILES:${PN} += "${base_libdir}/systemd/system/boot.mount ${base_libdir}/systemd/system/local-fs.target.wants/boot.mount"
