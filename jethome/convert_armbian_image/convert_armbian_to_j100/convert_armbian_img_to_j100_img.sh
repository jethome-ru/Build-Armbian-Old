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

set_swap_memory_percents_size() {
  if [[ -n "$1" || -n "$2" ]] ; then
    local new_size_in_percents_of_ram=$1
    local rootfs_dir=$2

    local file=$rootfs_dir/etc/default/armbian-zram-config
    local pattern="^# ZRAM_PERCENTAGE=50"
    local sed_string="s/"
    sed_string=${sed_string}$pattern
    sed_string=${sed_string}/ZRAM_PERCENTAGE=
    sed_string=${sed_string}$new_size_in_percents_of_ram
    sed_string=${sed_string}/g

    if grep -qP "$pattern" $file; then
      sed -i -e "$sed_string" $file
    else
      echo "${FUNCNAME[0]}(): Unable to grep \"$pattern\" in $file"
      exit 1
    fi
  else
    echo "${FUNCNAME[0]}(): Null parameter passed to this function"
  fi
}

set_swapfile() {
  if [[ -n "$1" || -n "$2" ]] ; then
    local swapfile_size_in_mibs=$1
    local rootfs_dir=$2

    local armbian_swapfile_path=/swapfile

    print_cmd_title "Setting $armbian_swapfile_path with size $swapfile_size_in_mibs MiBs"
    # disable armbian-zram-config.service
    # rm -v ${rootfs_dir}/etc/systemd/system/sysinit.target.wants/armbian-zram-config.service

    echo "dd if=/dev/zero of=${rootfs_dir}${armbian_swapfile_path} bs=1MiB count=$swapfile_size_in_mibs status=progress"
    dd if=/dev/zero of=${rootfs_dir}${armbian_swapfile_path} bs=1MiB count=$swapfile_size_in_mibs status=progress
    chmod -v 600 ${rootfs_dir}${armbian_swapfile_path}
    mkswap ${rootfs_dir}${armbian_swapfile_path}
    echo "\"$armbian_swapfile_path none swap sw 0 0\" >> $rootfs_dir/etc/fstab"
    echo "$armbian_swapfile_path none swap sw 0 0" >> $rootfs_dir/etc/fstab
  else
    echo "${FUNCNAME[0]}(): Null parameter passed to this function"
  fi
}

get_input_img "$INPUT_FILE"

echo

detect_partitions "$INPUT_IMG"

echo

extract_partition "BOOT" "$INPUT_IMG" "$BOOT_PARTITION_START" "$BOOT_PARTITION_SIZE" "$SYSTEM_IMG"

echo

extract_partition "ROOTFS" "$INPUT_IMG" "$ROOTFS_PARTITION_START" "$ROOTFS_PARTITION_SIZE" "$DATA_IMG"

echo

repack_rootfs_partition "set_swapfile" "128"

echo

# repack_rootfs_partition "set_swap_memory_percents_size" "100"

# echo

# shrink_rootfs_partition "$DATA_IMG"

# echo

print_cmd_title "Packing $OUTPUT_IMG ..."
./aml_image_v2_packer -r image.cfg ./ $OUTPUT_IMG
