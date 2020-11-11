#!/bin/bash

if [[ -n "${JETHOME_CUSTOMIZATION_NAME:-}" ]]; then
  install_customization_rootfs_patches

  echo
fi
