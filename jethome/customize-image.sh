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

embed_8822cs_driver() {
  local KVER=$(ls -1 /lib/modules | head -n 1)
  if [[ -n "$KVER" ]]; then
    echo "Copy rtl8822cs wifi driver..."
    cp -fv /tmp/overlay/88x2cs.ko /lib/modules/$KVER/kernel/drivers/net/wireless/

    echo "Modify /etc/rc.local..."
    local RC_LOCAL=/etc/rc.local
    # line number with last 'exit 0' in file
    local LINE_TO_INSERT=$(grep -n "^exit 0" $RC_LOCAL | tail -n 1 | cut -d: -f1)
    echo LINE_TO_INSERT=$LINE_TO_INSERT

    local RC_LOCAL_NEW=${RC_LOCAL}_new
    # generate new rc.local with inserted code snippet
    local LINE_NUM=0
    while IFS= read -r line
    do
      ((LINE_NUM=LINE_NUM+1))
      if [[ "$LINE_NUM" = $LINE_TO_INSERT ]]
      then
        cat /tmp/overlay/88x2cs_modprober >> $RC_LOCAL_NEW
        echo >> $RC_LOCAL_NEW
      fi
      echo "$line" >> $RC_LOCAL_NEW
    done < $RC_LOCAL
    mv -fv $RC_LOCAL_NEW $RC_LOCAL
    chmod -v +x $RC_LOCAL
    echo "New $RC_LOCAL content:"
    cat $RC_LOCAL
  else
    echo "Error: customize-image.sh::Main()::KVER is empty"
  fi
}

Main() {
  case $RELEASE in
    focal)
      if [[ "$LINUXFAMILY" = "arm-64" ]]; then
        if [[ "$BOARD" = "arm-64" ]]; then
          embed_8822cs_driver
        fi
      fi
      ;;
  esac
} # Main

Main "$@"
