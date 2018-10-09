#
#
class profile::base::dell
{
  if fact('dmi.product.name') =~ '^PowerEdge [RTM][1-9][1-4]0.*' {

    # find Dell yum repos
    $repo_hash = lookup('profile::base::dell::repo_hash', Hash, 'deep', {})

    # get Dell packages
    $packages = lookup('profile::base::dell::packages', Hash, 'deep', {})

    # Install repos and packages
    create_resources('yumrepo', $repo_hash) ->
    create_resources('profile::base::package', $packages)

    # OMSA daemons
    service { "instsvcdrv":
      ensure => running,
      enable => true,
    } ->
    service { "dataeng":
      ensure => running,
      enable => true,
    } ->
    service { "dsm_om_connsvc":
      ensure => running,
      enable => true,
    } ->
    service { "dsm_om_shrsvc":
      ensure => running,
      enable => true,
    }

    # Configure snmpd.conf
    exec { "enable snmp":
      command => "/etc/init.d/dataeng enablesnmp",
      unless  => "/bin/grep -q ^smuxpeer /etc/snmp/snmpd.conf",
      notify  => Service['snmpd'],
    }

    # SNMP daemon
    service { "snmpd":
      ensure  => running,
      enable  => true,
      require => Package['net-snmp']
    }

  }
}
