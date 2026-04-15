#!/bin/bash

# ipv6 exported bird routes
rr1_ipv6=$(birdc show route export rr1_ipv6 | grep kernel | wc -l)
rr2_ipv6=$(birdc show route export rr2_ipv6 | grep kernel | wc -l)

# ipv4 exported bird routes
rr1_ipv4=$(birdc show route export rr1_ipv4 | grep kernel | wc -l)
rr2_ipv4=$(birdc show route export rr2_ipv4 | grep kernel | wc -l)

# kernel routes added by calico
ipv6_routes=$(ip -6 -d r | grep tap | grep -v 'fe80::/64' | grep 'proto boot' | wc -l)
ipv4_routes=$(ip -d r | grep tap | grep 'proto boot' | wc -l)

if [ "${rr1_ipv4}" -eq "${ipv4_routes}" ] || [ ${rr2_ipv4} -eq ${ipv4_routes} ]; then
    echo "IPv4 bird prefix match kernel routes"
else
    echo "IPv4 bird prefix do not match kernel routes"
    echo "Kernel routes=${ipv4_routes}"
    echo "IPv4 rr1 prefix=${rr1_ipv4}"
    echo "IPv4 rr2 prefix=${rr2_ipv4}"
    exit 1
fi

if [ "${rr1_ipv6}" -eq "${ipv6_routes}" ] || [ ${rr2_ipv6} -eq ${ipv6_routes} ]; then
    echo "IPv6 bird prefix match kernel routes"
else
    echo "IPv6 bird prefix do not match kernel routes"
    echo "Kernel routes=${ipv6_routes}"
    echo "IPv6 rr1 prefix=${rr1_ipv6}"
    echo "IPv6 rr2 prefix=${rr2_ipv6}"
    exit 1
fi

exit 0
