FILESEXTRAPATHS:prepend := "${THISDIR}/tegra-minimal-init:"

SRC_URI += "file://fde-init-boot.sh"


do_install:append(){

       case "${DISTRO_FEATURES}" in
        *enc-rootfs*)
		    install -m 0755 ${WORKDIR}/fde-init-boot.sh ${D}/init
               ;;
       esac
}
