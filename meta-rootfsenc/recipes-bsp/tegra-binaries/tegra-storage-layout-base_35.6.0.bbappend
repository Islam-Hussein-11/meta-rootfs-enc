PARTITION_FILE = "${DEPLOY_DIR_IMAGE}/${PARTITION_LAYOUT_TEMPLATE}"

do_install[depends] += "custom-flash-layout:do_deploy"
