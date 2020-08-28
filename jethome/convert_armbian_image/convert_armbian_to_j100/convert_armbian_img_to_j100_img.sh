#/bin/bash -x
#
# -x        Print commands and their arguments as they are executed.

set -e # Exit immediately if a command exits with a non-zero status
set -u # Treat unset variables and parameters as an error

. ../convert_armbian_common/functions.sh

I=$(self_name)

if [[ $# != 2 ]]; then
  j100_usage "$I"
fi

INPUT_FILE=$1
OUTPUT_IMG=$2

SYSTEM_IMG=system_a.PARTITION
DATA_IMG=data.PARTITION

get_input_img "$INPUT_FILE"

echo

detect_partitions "$INPUT_IMG"

echo

extract_partition "BOOT" "$INPUT_IMG" "$BOOT_PARTITION_START" "$BOOT_PARTITION_SIZE" "$SYSTEM_IMG"

echo

extract_partition "ROOTFS" "$INPUT_IMG" "$ROOTFS_PARTITION_START" "$ROOTFS_PARTITION_SIZE" "$DATA_IMG"

echo

# shrink_rootfs_partition "$DATA_IMG"

# echo

print_cmd_title "Packing $OUTPUT_IMG ..."
./aml_image_v2_packer -r image.cfg ./ $OUTPUT_IMG
