#!/bin/bash

if [[ $# != 2 ]]; then
  s905_usage "$I" "$S905_VARIANT"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_IMG=$2

get_input_img "$INPUT_FILE"

echo

detect_partitions "$INPUT_IMG"

echo

extract_partition "BOOT" "$INPUT_IMG" "$BOOT_PARTITION_START" "$BOOT_PARTITION_SIZE" "$SYSTEM_IMG"

echo

extract_partition "ROOTFS" "$INPUT_IMG" "$ROOTFS_PARTITION_START" "$ROOTFS_PARTITION_SIZE" "$DATA_IMG"

echo

. ../convert_armbian_common/try_install_customization_rootfs_patches.sh

# shrink_rootfs_partition "$DATA_IMG"

# echo

print_cmd_title "Packing $OUTPUT_IMG ..."
./aml_image_v2_packer -r default.cfg ./ $OUTPUT_IMG
