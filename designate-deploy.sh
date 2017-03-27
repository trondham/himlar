#!/bin/bash
#
# run as root!

ZONE_NAME='vm.vagrant.org'

. /root/openrc

# fix iptables (FIXME: should be done by puppet)
iptables -I INPUT 1 -m multiport -p tcp --ports 5354 -j ACCEPT

# Create a server
designate server-create --name $(hostname).

# Create our zone
designate domain-create --name ${ZONE_NAME}. --email root@${ZONE_NAME}

# Get the zone ID
ZONE_ID=$(designate domain-list | grep $ZONE_NAME | awk '{print $2}')

# Register an A record within the zone
designate record-create --name dummy1.${ZONE_NAME}. --type A --data 1.1.1.1 $ZONE_ID

# Check that the A record has propagated to the name servers
dig +short -p 53 @ns1.vagrant.iaas.intern dummy1.${ZONE_NAME} A
dig +short -p 53 @ns2.vagrant.iaas.intern dummy1.${ZONE_NAME} A

# Configure [handler:nova_fixed] in designate.conf
openstack-config --set /etc/designate/designate.conf handler:nova_fixed zone_id $ZONE_ID
openstack-config --set /etc/designate/designate.conf handler:nova_fixed format "'vm-%(octet0)s-%(octet1)s-%(octet2)s-%(octet3)s.%(zone)s'"

# Configure [service:api] in designate.conf
openstack-config --set /etc/designate/designate.conf service:api enabled_extensions_v1 'diagnostics, quotas, reports, sync, touch'
openstack-config --set /etc/designate/designate.conf service:api enabled_extensions_v2 'quotas, reports'

# Restart services
systemctl restart designate-api
systemctl restart designate-central
systemctl restart designate-mdns
systemctl restart designate-pool-manager
systemctl restart designate-sink
