#!/bin/bash

set -e

. /opt/kolla/kolla-common.sh
. /opt/kolla/config-cinder.sh
. /opt/kolla/volume-group-create.sh

check_required_vars CINDER_VOLUME_API_LISTEN ISCSI_HELPER ISCSI_IP_ADDRESS \
                    CINDER_VOLUME_GROUP CINDER_LVM_LO_VOLUME_SIZE \
                    CINDER_VOLUME_BACKEND_NAME CINDER_VOLUME_DRIVER \
                    CINDER_ENABLED_BACKEND CINDER_VOLUME_LOG_FILE

cfg=/etc/cinder/cinder.conf

# Logging
crudini --set $cfg \
    DEFAULT \
    log_file \
    "${CINDER_VOLUME_LOG_FILE}"

# IP address on which OpenStack Volume API listens
crudini --set $cfg \
    DEFAULT \
    osapi_volume_listen \
    "${CINDER_VOLUME_API_LISTEN}"

# The IP address that the iSCSI daemon is listening on
crudini --set $cfg \
    DEFAULT \
    iscsi_ip_address \
    "${ISCSI_IP_ADDRESS}"

# Set to false when using loopback devices (testing)
crudini --set $cfg \
    DEFAULT \
    secure_delete \
    "false"

crudini --set $cfg \
    DEFAULT \
    enabled_backends \
    "${CINDER_ENABLED_BACKEND}"

crudini --set $cfg \
    lvm57 \
    iscsi_helper \
    "${ISCSI_HELPER}"

crudini --set $cfg \
    lvm57 \
    volume_group \
    "${CINDER_VOLUME_GROUP}"

crudini --set $cfg \
    lvm57 \
    volume_driver \
    "${CINDER_VOLUME_DRIVER}"

crudini --set $cfg \
    lvm57 \
    iscsi_ip_address \
    "${ISCSI_IP_ADDRESS}"

crudini --set $cfg \
    lvm57 \
    volume_backend_name \
    "${CINDER_VOLUME_BACKEND_NAME}"

sed -i 's/udev_sync = 1/udev_sync = 0/' /etc/lvm/lvm.conf
sed -i 's/udev_rules = 1/udev_rules = 0/' /etc/lvm/lvm.conf
sed -i 's/use_lvmetad = 1/use_lvmetad = 0/' /etc/lvm/lvm.conf

echo "Starting cinder-volume"
exec /usr/bin/cinder-volume --config-file /etc/cinder/cinder.conf
