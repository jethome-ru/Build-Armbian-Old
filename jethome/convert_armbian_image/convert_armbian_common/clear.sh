#/bin/bash -x
#
# -x        Print commands and their arguments as they are executed.

rm -v --interactive {rootfs,boot}.PARTITION AML_UPGRADE/{rootfs,boot}.img *.img
