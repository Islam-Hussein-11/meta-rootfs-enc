DESCRIPTION = "Custom flash layout files"
LICENSE = "CLOSED"

INHIBIT_DEFAULT_DEPS = "1"
COMPATIBLE_MACHINE = "(tegra)"

SRC_URI = "file://${PARTITION_LAYOUT_TEMPLATE}"

S = "${WORKDIR}"

do_compile[noexec] = "1"

do_deploy() {
    install -d ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${WORKDIR}/${PARTITION_LAYOUT_TEMPLATE} ${DEPLOY_DIR_IMAGE}/
}

addtask deploy after do_compile before do_install


PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit nopackages
