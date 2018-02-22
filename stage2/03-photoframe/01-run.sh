#!/bin/bash -e

on_chroot << EOF
systemctl disable getty@tty1.service
systemctl mask plymouth-start.service
EOF

install -m 644 files/colortemp_info.txt ${ROOTFS_DIR}/root/colortemp_info.txt
install -m 644 files/http-auth.json ${ROOTFS_DIR}/boot/http-auth.json

# Remove wait on network
rm ${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/wait.conf

# Cannot be run with QEMU since it will hang
git clone -v https://github.com/mrworf/photoframe.git ${ROOTFS_DIR}/root/photoframe

on_chroot << EOF
echo "done git cloning"
cd /root/photoframe
echo "cd"
cp frame.service /etc/systemd/system/
echo "copy"
systemctl enable /etc/systemd/system/frame.service
echo "systemctl"
# Enable auto update
echo >>/etc/crontab "15 3    * * *   root    /root/photoframe/update.sh"
EOF
