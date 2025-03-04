PACKAGE_INSTALL:append = "${@bb.utils.contains("DISTRO_FEATURES", "enc-rootfs", "libcrypto efivar cryptsetup libgcc optee-nvsamples", "", d)}"
#Packages recommended by libcrypto package and looks like they are not actually needed,
#so we are removing them to keep initrd image to a minimum
BAD_RECOMMENDATIONS:append = "${@bb.utils.contains("DISTRO_FEATURES", "enc-rootfs", " openssl-conf openssl-ossl-module-legacy", "", d)}"
