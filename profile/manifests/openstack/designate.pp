class profile::openstack::designate (
  $manage_designate = false,
  $my_zones = {},
  $my_nameservers = {},
  $my_pools = {},
  $my_targets = {},
  $dns_master = {},
  $dns_slave01 = {},
  $dns_slave02 = {},
  $mdns_server = {},
)
{
  include ::designate
  if $manage_designate {
    include ::designate::db
    include ::designate::api
    include ::designate::central
    include ::designate::pool_manager
    include ::designate::mdns
    include ::designate::sink

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
}
