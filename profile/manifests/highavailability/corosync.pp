#
# Management of both the software stack (pacemaker and corosync)
# and the cluster resources
#
class profile::highavailability::corosync(
  $manage_corosync = false,
  $manage_firewall = false,
  $properties      = {},
  $primitives      = {},
  $locations       = {},
  $colocations     = {},
  $clones          = {},
  $firewall_extras = {}
) {

  if $manage_corosync {
    include ::corosync

    create_resources('cs_property', $properties)
    create_resources('cs_primitive', $primitives)
    create_resources('cs_location', $locations)
    create_resources('cs_colocation', $colocations)
    create_resources('cs_clone', $clones)
  }

  if $manage_firewall {
    profile::firewall::rule { '460 corosync udp':
      proto       => 'udp',
      dport       => '5405',
      destination => $::ipaddress_public1,
      extras      => $firewall_extras
    }
  }
}
