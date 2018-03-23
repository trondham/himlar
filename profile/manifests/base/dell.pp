# 
#
class profile::base::dell
{
  if fact('dmi.product.name') =~ '^PowerEdge [RTM][1-9][1-4]0.*' {
 
    # Install Dell yum repos
    $repo_hash = lookup('profile::base::dell::repo_hash', Hash, 'deep', {})
    create_resources('yumrepo', $repo_hash)

    # Install Dell packages
    $packages = lookup('profile::base::dell::packages', Hash, 'deep', {})
    create_resources('profile::base::package', $packages)


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
