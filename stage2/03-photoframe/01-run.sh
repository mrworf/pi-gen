#!/bin/bash -e

on_chroot << EOF
systemctl disable getty@tty1.service
EOF

on_chroot << EOF
install -m 644 files/colortemp_info.txt ${ROOTFS_DIR}/root/colortemp_info.txt
EOF

on_chroot << EOF
git clone https://github.com/mrworf/photoframe.git
cd photoframe
cp frame.service /etc/systemd/system/
systemctl enable /etc/systemd/system/frame.service
EOF
