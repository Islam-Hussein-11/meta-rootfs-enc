# meta-rootfs-enc
This is a demo Layer Combined with encryption script to provide Rootfs Encytption for Jetson-Xavier-NX-emmc device


# Add These to you local.conf
```
PARTITION_LAYOUT_TEMPLATE = "flash_xavier_nx_enc.xml"
DISTRO_FEATURES:append = " enc-rootfs"
```

# WARNING
This only works with jetson-xavier-nx-emmc model.