class profile::openstack::cloudkitty (
  $manage_firewall = false
)
{
  include ::cloudkitty
  include ::cloudkitty::db
  include ::cloudkitty::api
  include ::cloudkitty::wsgi::apache
  include ::cloudkitty::keystone::authtoken

  if $manage_firewall {
    profile::firewall::rule { '001 cloudkitty incoming':
      port   => 8889,
      proto  => 'tcp'
    }
  }
}