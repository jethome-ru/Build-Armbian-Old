#/bin/bash -x
#
# -x        Print commands and their arguments as they are executed.

set -e # Exit immediately if a command exits with a non-zero status

# Script parameters handling
while [[ "${1}" == *=* ]]; do
    parameter=${1%%=*}
    value=${1##*=}
    shift
    echo "$0: setting $parameter to" "${value:-(empty)}"
    eval "$parameter=\"$value\""
done

set -u # Treat unset variables and parameters as an error

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

JETHOME=$SRC/jethome
USERPATCHES=$SRC/userpatches
USERPATCHES_KERNEL_ARM_64=$USERPATCHES/kernel/arm-64-current
USERPATCHES_SOURCES_FAMILIES=$USERPATCHES/sources/families
USERPATCHES_OVERLAY=$USERPATCHES/overlay

if [[ -n "${CUSTOMIZATION_NAME:-}" ]]; then
	if [[ ! -d $JETHOME/customization/${CUSTOMIZATION_NAME:-} ]]; then
		echo "Customization \"${CUSTOMIZATION_NAME:-}\" does not exist"
		exit 1
	fi
	USERPATCHES_OVERLAY_CUSTOMIZATION_PREBUILT_DEBS=$USERPATCHES_OVERLAY/packages/customization/${CUSTOMIZATION_NAME:-}
	USERPATCHES_OVERLAY_CUSTOMIZATION_ROOTFS_PATCHES=$USERPATCHES_OVERLAY/rootfs_patches/${CUSTOMIZATION_NAME:-}
fi

mkdir -pv $USERPATCHES_KERNEL_ARM_64
mkdir -pv $USERPATCHES_SOURCES_FAMILIES
mkdir -pv $USERPATCHES_OVERLAY

rm -fv $USERPATCHES_KERNEL_ARM_64/*

RM_USERPATCHES_OVERLAY="rm -frv $USERPATCHES_OVERLAY/*"

if [[ "${EUID}" == "0" ]]; then
	$RM_USERPATCHES_OVERLAY
elif grep -q "$(whoami)" <(getent group docker); then
	$RM_USERPATCHES_OVERLAY
else
	sudo $RM_USERPATCHES_OVERLAY
fi

cp -fv $JETHOME/patch/kernel/arm-64-current/* $USERPATCHES_KERNEL_ARM_64/
cp -fv $JETHOME/patch/sources/families/arm-64.conf $USERPATCHES_SOURCES_FAMILIES/
cp -frv $JETHOME/overlay/* $USERPATCHES_OVERLAY/
cp -fv $JETHOME/customize-image.sh $USERPATCHES/
cp -fv $JETHOME/lib.config $USERPATCHES/

if [[ -n "${CUSTOMIZATION_NAME:-}" ]]; then
	mkdir -pv $USERPATCHES_OVERLAY_CUSTOMIZATION_PREBUILT_DEBS
	cp -fv $JETHOME/customization/${CUSTOMIZATION_NAME:-}/packages/*.deb $USERPATCHES_OVERLAY_CUSTOMIZATION_PREBUILT_DEBS/
	mkdir -pv $USERPATCHES_OVERLAY_CUSTOMIZATION_ROOTFS_PATCHES
	cp -frv $JETHOME/customization/${CUSTOMIZATION_NAME:-}/rootfs_patches/* $USERPATCHES_OVERLAY_CUSTOMIZATION_ROOTFS_PATCHES/
fi

echo "${CUSTOMIZATION_NAME:-}" > $USERPATCHES_OVERLAY/CUSTOMIZATION_NAME

./compile.sh docker \
CUSTOMIZATION_NAME="${CUSTOMIZATION_NAME:-}" \
CLEAN_LEVEL="make,alldebs,oldcache" \
BUILD_KSRC=yes \
BOARD=arm-64 \
BRANCH=current \
RELEASE=focal \
BUILD_MINIMAL=no \
BUILD_DESKTOP=no \
KERNEL_ONLY=no \
KERNEL_CONFIGURE=no \
CREATE_PATCHES=no \
COMPRESS_OUTPUTIMAGE=sha,gpg,img \
LIB_TAG=jethome
