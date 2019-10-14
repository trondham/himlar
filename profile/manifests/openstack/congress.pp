class profile::openstack::congress (
  $manage_firewall = false
)
{
  include ::congress
  include ::congress::db

  if $manage_firewall {
    profile::firewall::rule { '001 congress incoming':
      port   => 1789,
      proto  => 'tcp'
    }
  }
}