#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -u # Treat unset variables and parameters as an error

. ../convert_armbian_common/functions.sh
. ../convert_armbian_common/s905/common.sh

S905_VARIANT=j80
I=$(self_name)

. ../convert_armbian_common/s905/convert_armbian_imgxz_to_s905_img.sh
