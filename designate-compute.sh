#!/bin/bash
#
# run as root!

# Configure [DEFAULT] in nova.conf
openstack-config --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
openstack-config --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
openstack-config --set /etc/nova/nova.conf DEFAULT instance_usage_audit true

# Configure [oslo_messaging_notifications] in nova.conf
openstack-config --set /etc/nova/nova.conf oslo_messaging_notifications driver messagingv2
openstack-config --set /etc/nova/nova.conf oslo_messaging_notifications topics notifications

# Restart services
openstack-service restart nova
systemctl restart openstack-nova-compute
systemctl restart openstack-nova-metadata-api



# qemu stuff
cat <<EOF >/etc/yum.repos.d/trondham.repo
[trondham]
name=Trond
baseurl=http://folk.uio.no/trondham/qemu/$basearch
enabled=1
gpgcheck=0
EOF
yum upgrade -y
