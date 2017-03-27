#!/bin/bash
#
# run as root!

# How to create RPM package:
# ==========================
# 
# Install tools:
# 
#   yum install /usr/bin/rpmspec
# 
# Get designate-dashboard from GitHub:
# 
#   git clone https://github.com/openstack/designate-dashboard.git
#   cd designate-dashboard
#   git checkout stable/mitaka
# 
# Build RPM:
# 
#   python setup.py bdist_rpm
#


# Install RPMs that the designate-dashboard RPM requires
yum -y install python2-designateclient

# Install RPM
rpm -ivh http://folk.uio.no/trondham/designate/designate-dashboard/dist/designate-dashboard-2.1.0-1.noarch.rpm

# Copy plugins
cp /usr/lib/python2.7/site-packages/designatedashboard/enabled/_17*.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/

# Restart Apache
service httpd restart
