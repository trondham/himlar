class profile::openstack::designate (
  $manage_designate = false,
  $manage_designate_bind = false,
  $my_zones = {},
  $my_nameservers = {},
  $my_pools = {},
  $my_targets = {},
){
  include ::designate
  if $manage_designate {
    include ::designate::db
    include ::designate::api
    include ::designate::central
    include ::designate::pool_manager
#    include ::designate::pool_manager_cache::memcache
    include ::designate::mdns
    include ::designate::sink
#    include ::designate::backend::bind9
    if $my_nameservers {
       create_resources('designate::pool_nameserver', $my_nameservers)
    }
    if $my_pools {
       create_resources('designate::pool', $my_pools)
    }
    if $my_targets {
       create_resources('designate::pool_target', $my_targets)
    }

    file { '/etc/designate/zone_config.yaml':
      content      => template("${module_name}/openstack/designate/zone_config.yaml.erb"),
      mode         => '0644',
      owner        => 'root',
      group        => 'root',
      notify       => Exec['fix_designate_pools'],
    } ->
    exec { 'fix_designate_pools':
      command     => '/usr/bin/designate-manage pool update --file /etc/designate/zone_config.yaml',
      refreshonly => true,
    }

  }
  if $manage_designate_bind {
    package { 'bind':
      ensure => installed,
    } ->
    exec { '/usr/sbin/rndc-confgen -a':
      creates => '/etc/rndc.key',
    } ->
    file { '/etc/rndc.key':
      mode         => '0600',
      owner        => 'named',
      group        => 'named',
    } ->
    file { '/etc/rndc.conf':
      content      => template("${module_name}/openstack/designate/rndc.conf.erb"),
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
    } ->
    file { '/etc/named.conf':
      content      => template("${module_name}/openstack/designate/named.conf.erb"),
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      validate_cmd => '/usr/sbin/named-checkconf %',
    } ->
    file { '/var/named':
      ensure       => directory,
      mode         => '0770',
      owner        => 'root',
      group        => 'named',
    } ->
    exec { '/usr/sbin/setsebool -P named_write_master_zones on':
      unless => "/usr/sbin/getsebool named_write_master_zones | /usr/bin/egrep -q 'on$'",
    } ->
    service { 'named':
      ensure => running,
      enable => true,
    }
  }
}
