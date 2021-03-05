usb start
setenv bootargs ${armbian_APPEND} root=${armbian_root_device}
run armbian_keyman
run armbian_addids
fatload usb 0 ${armbian_kernel_addr_r} ${armbian_LINUX}
fatload usb 0 ${armbian_ramdisk_addr_r} ${armbian_INITRD}
fatload usb 0 ${armbian_fdt_addr_r} ${armbian_FDT}
booti ${armbian_kernel_addr_r} ${armbian_ramdisk_addr_r} ${armbian_fdt_addr_r}

