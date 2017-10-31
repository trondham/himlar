# Class: profile::storage::cephmon_firewall
#
#
class profile::storage::cephmon_firewall(
  $manage_firewall = false,
  $firewall_extras = {
    'mon_listen'   => {},
  },
) {
  if $manage_firewall {
    profile::firewall::rule { '100 ceph-mon accept tcp':
      dport  => 6789,
      extras => $firewall_extras['mon_listen']
    }
    profile::firewall::rule { '101 ceph-mgr accept tcp':
      dport  => 6800,
      extras => $firewall_extras['mgr_listen']
    }
  }
}
