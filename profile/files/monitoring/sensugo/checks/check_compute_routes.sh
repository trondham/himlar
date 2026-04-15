#!/bin/bash

rr1_ipv6=$(birdc show route export rr1_ipv6 | grep kernel | wc -l)
rr2_ipv6=$(birdc show route export rr2_ipv6 | grep kernel | wc -l)

rr1_ipv4=$(birdc show route export rr1_ipv4 | grep kernel | wc -l)
rr2_ipv4=$(birdc show route export rr2_ipv4 | grep kernel | wc -l)

running_vms=$(virsh list --state-running | grep -c 'running')

ipv6_routes=$(ip -6 r | grep tap | grep -v 'fe80::/64' | wc -l)
ipv4_routes=$(ip -br r | grep tap | wc -l)

if [ "${rr1_ipv4}" -eq "${running_vms}" ] || [ ${rr2_ipv4} -eq ${running_vms} ]; then
    echo "IPv4 bird prefix match running vms"
else
    echo "IPv4 bird prefix do not match running vms"
    echo "Running VMs=${running_vms}"
    echo "IPv4 rr1 prefix=${rr1_ipv4}"
    echo "IPv4 rr2 prefix=${rr2_ipv4}"
    exit 1
fi

if [ "${ipv4_routes}" -eq "${running_vms}" ]; then
    echo "IPv4 routes match running vms"
else
    echo "IPv4 routes do not match running vms"
    echo "Running VMs=${running_vms}"
    echo "IPv4 routes=${ipv4_routes}"
    exit 1
fi

if [ "${rr1_ipv6}" -eq "${running_vms}" ] || [ ${rr2_ipv6} -eq ${running_vms} ]; then
    echo "IPv6 bird prefix match running vms"
else
    echo "IPv6 bird prefix do not match running vms"
    echo "Running VMs=${running_vms}"
    echo "IPv6 rr1 prefix=${rr1_ipv6}"
    echo "IPv6 rr2 prefix=${rr2_ipv6}"
    exit 1
fi

if [ "${ipv6_routes}" -eq "${running_vms}" ]; then
    echo "IPv6 routes match running vms"
else
    echo "IPv6 routes do not match running vms"
    echo "Running VMs=${running_vms}"
    echo "IPv6 routes=${ipv6_routes}"
    exit 1
fi

exit 0
