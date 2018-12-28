#!/bin/bash -e

# Disable first console and boot messages
on_chroot << EOF
systemctl disable getty@tty1.service
systemctl mask plymouth-start.service
EOF

# Create config folder
mkdir ${ROOTFS_DIR}/root/photoframe_config

# Add info files
install -m 644 files/colortemp_info.txt ${ROOTFS_DIR}/root/photoframe_config/colortemp_info.txt

# Add default authentication
install -m 644 files/http-auth.json ${ROOTFS_DIR}/boot/http-auth.json

# Add fix_wifi.sh for when wpa_supplicant fails
install -m 755 files/fix_wifi.sh ${ROOTFS_DIR}/root/fix_wifi.sh
install -m 644 files/fixwifi.service ${ROOTFS_DIR}/etc/systemd/system/

# Remove wait on network
rm ${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/wait.conf

# If this directory doesn't exist, clone a branch of it
if [ "${PHOTOFRAME_SRC}" = "" ]; then
  # Cannot be run with QEMU since it will hang
  git clone -v -b ${PHOTOFRAME_BRANCH} https://github.com/mrworf/photoframe.git ${ROOTFS_DIR}/root/photoframe
else
  echo "Using ${PHOTOFRAME_SRC} as the basis for the photoframe software"
  mkdir -p ${ROOTFS_DIR}/root/photoframe
  for X in $(ls -A1 ${PHOTOFRAME_SRC}) ; do
    if [[ "$X" != */pi-gen ]]; then
      cp -dprv "${PHOTOFRAME_SRC}/$X" ${ROOTFS_DIR}/root/photoframe/
    fi
  done
fi

on_chroot << EOF
cd /root/photoframe
cp frame.service /etc/systemd/system/
systemctl enable /etc/systemd/system/frame.service

# Also enable the fixwifi
systemctl enable /etc/systemd/system/fixwifi.service

# Enable auto update
echo >>/etc/crontab "15 3    * * *   root    /root/photoframe/update.sh"

# Add missing i2c-dev modules for color sensor
echo >>/etc/modules "i2c-dev"
EOF
