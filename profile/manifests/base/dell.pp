# 
#
class profile::base::dell
{
  if fact('dmi.product.name') =~ '^PowerEdge [RTM][1-9][1-4]0.*' {
 
    $repo_hash = lookup('profile::base::dell::repo_hash', Hash, 'deep', {})
    class { '::openstack_extras::repo::redhat::redhat':
      repo_hash => $repo_hash
    }

    # install dell repos
    # install dell gpg keys
    # install omsa
    #   /usr/bin/yum -y -q install srvadmin-all
    # install DSU
    #   /usr/bin/yum -y -q install dell-system-update
    # start srvadmin
    #   /opt/dell/srvadmin/sbin/srvadmin-services.sh start
    # skru på snmp
    #   /etc/init.d/dataeng enablesnmp
    # restart snmpd
    #   systemctl -q restart snmpd.service
    # konfigurere omsa
    #   sette ting i /opt/dell/srvadmin/etc/srvadmin-omilcore/install.ini
  }
}
