#!/bin/bash

# run as root!
if [ $UID -ne 0 ]; then
    echo >&2 "ERROR: This script must be run as root"
    exit 1
fi

# Set proper path
PATH=/usr/bin
export PATH

# Our zone
LOC=$(hostname | cut -d- -f1)
ZONE_NAME="customer.${LOC}.uh-iaas.no"

# Source appropriate keystone credentials file
if [ "$LOC" = "vagrant" ]; then
    . /root/openrc
    export OS_USERNAME=admin
    export OS_PROJECT_NAME=openstack
    export OS_PASSWORD=admin_pass
    export PS1='[\u@\h \W(keystone_vagrant_admin)]$ '
else
    [ -f /root/openrc_admin ] || exit 1
    . /root/openrc_admin
fi

# Update pools config (also done by puppet)
designate-manage pool update --file /etc/designate/pools.yaml

# Create our zone
openstack zone show ${ZONE_NAME}. -c id -f value >/dev/null 2>&1 || \
    openstack zone create ${ZONE_NAME}. --email support@uh-iaas.no

# Get the zone ID
ZONE_ID=$(openstack zone show ${ZONE_NAME}. -c id -f value)

# Configure [handler:nova_fixed] in designate.conf
CONFIGURED_ZONE_ID=$(crudini --get /etc/designate/designate.conf handler:nova_fixed zone_id)
if [ "$CONFIGURED_ZONE_ID" != "$ZONE_ID" ]; then
    crudini --set /etc/designate/designate.conf handler:nova_fixed zone_id $ZONE_ID
fi

# Restart services
systemctl restart designate-api
systemctl restart designate-central
systemctl restart designate-mdns
systemctl restart designate-pool-manager
systemctl restart designate-sink

# Exit properly
exit 0
