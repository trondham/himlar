#!/bin/bash
#
# run as root!

# qemu stuff
cat <<EOF >/etc/yum.repos.d/trondham.repo
[trondham]
name=Trond
baseurl=http://folk.uio.no/trondham/qemu/$basearch
enabled=1
gpgcheck=0
EOF
yum upgrade -y
