#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

print_title() {
  if [ -n "$1" ] ; then
    echo "###### ${1} ######"
  else
    echo "${FUNCNAME[0]}(): Null parameter passed to this function"
  fi
}


create_deb_packages() {
  print_title "Creating deb packages iterating *.conf files"
  mkdir -v /tmp/overlay/debs
  for package_script in /tmp/overlay/packages/*.conf; do
    source $package_script
  done
}

customization_install_prebuilt_packages() {
  print_title "Installing customization prebuilt packages"
  local customization_prebuilt_debs
  customization_prebuilt_debs=$(</tmp/overlay/CUSTOMIZATION_PREBUILT_DEBS)
  if [[ -n "$customization_prebuilt_debs" ]]; then
    for package_deb_file in /tmp/overlay/packages/customization/$customization_prebuilt_debs/*.deb; do
      DEBIAN_FRONTEND=noninteractive apt -yqq --no-install-recommends install "$package_deb_file"
    done
  fi
}

customization_install_rootfs_patches() {
  print_title "Installing customization rootfs patches"
  local customization_rootfs_patches
  customization_rootfs_patches=$(</tmp/overlay/CUSTOMIZATION_ROOTFS_PATCHES)
  if [[ -n "$customization_rootfs_patches" ]]; then
    local patch_dir="/tmp/overlay/rootfs_patches/$customization_rootfs_patches"
    if [[ -d ${patch_dir} && ! -z `ls ${patch_dir}` ]]; then
      echo "----> copying patches from ${patch_dir}"
      cp -rvf ${patch_dir}/* ./
    else
      echo "----> skipping patches from ${patch_dir}"
    fi
  fi
}

create_brcm_symlinks() {
  print_title "Creating brcm symlinks"
  ln -vs brcmfmac43455-sdio.txt /usr/lib/firmware/brcm/brcmfmac43455-sdio.amlogic,s400.txt
  ln -vs ../BCM4345C0.hcd /usr/lib/firmware/brcm/BCM4345C0.hcd

  ls -lhA /usr/lib/firmware/brcm/brcmfmac43455-sdio.amlogic,s400.txt
  ls -lhA /usr/lib/firmware/brcm/BCM4345C0.hcd
}

Main() {
  case $RELEASE in
    focal)
      if [[ "$LINUXFAMILY" = "arm-64" ]]; then
        if [[ "$BOARD" = "arm-64" ]]; then
          create_deb_packages
          customization_install_prebuilt_packages
          customization_install_rootfs_patches
          create_brcm_symlinks
        fi
      fi
      ;;
  esac
} # Main

Main "$@"
