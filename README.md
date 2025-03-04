# meta-rootfs-enc
This is a demo Layer Combined with encryption script to provide Rootfs Encytption for Jetson-Xavier-NX-emmc device


# Add These to you local.conf
```
PARTITION_LAYOUT_TEMPLATE = "flash_xavier_nx_enc.xml"
DISTRO_FEATURES:append = " enc-rootfs"
```

After bitbaking the Image run encryption script
```
cd encryption
./encryption
```

You will find the encrypted Tegraflash file in $DEPLOY_DIR with -encrypted at the end of naming.

Please Provide your issues as I've faced some issues with flashing I'll provide in the future the calculations of sizes in detail.


# WARNING
This only works with jetson-xavier-nx-emmc model.