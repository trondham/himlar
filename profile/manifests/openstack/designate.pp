class profile::openstack::designate (
  $my_zones = {},
  $my_nameservers = {},
  $my_pools = {},
  $my_targets = {},
  $mdns_transport_addr = {},
  $ns1_transport_addr = {},
  $ns2_transport_addr = {},
  $ns1_public_addr = {},
  $ns2_public_addr = {},
  $ns1_public_name = {},
  $ns2_public_name = {},
  $manage_firewall = false,
)
{
  include ::designate
  include ::designate::db
  include ::designate::api
  include ::designate::central
  include ::designate::pool_manager
  include ::designate::mdns
  include ::designate::sink
  include ::designate::config

  class { selinux:
    mode => 'enforcing',
    type => 'targeted',
  }
  package { 'openstack-selinux':
    ensure => installed,
  }

  if $my_nameservers {
    create_resources('designate::pool_nameserver', $my_nameservers)
  }
  if $my_pools {
    create_resources('designate::pool', $my_pools)
  }
  if $my_targets {
    create_resources('designate::pool_target', $my_targets)
  }

  file { '/etc/designate/pools.yaml':
    content      => template("${module_name}/openstack/designate/pools.yaml.erb"),
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
    notify       => Exec['fix_designate_pools'],
  } ->
  exec { 'fix_designate_pools':
    command     => '/usr/bin/designate-manage pool update --file /etc/designate/pools.yaml',
    refreshonly => true,
  }

  package { 'bind':
    ensure => installed,
  }
  file { '/etc/rndc.conf':
    content      => template("${module_name}/openstack/designate/rndc.conf.erb"),
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }
  file { '/etc/rndc.key':
    source  => "puppet:///modules/${module_name}/openstack/designate/rndc.key",
    ensure  => file,
    mode    => '0600',
    owner   => 'named',
    group   => 'named',
    require => Package['bind'],
  }

  if $manage_firewall {
    profile::firewall::rule { '001 designate incoming':
      port   => 9001,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 designate mdns incoming':
      port   => 5354,
      proto  => 'tcp'
    }
  }
}
