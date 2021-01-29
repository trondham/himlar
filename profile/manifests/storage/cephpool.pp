# Class: profile::storage::cephpool
#
#
class profile::storage::cephpool (
  $manage_ec_pools        = false,
  $manage_cephpool_params = false,
  $manage_repl_pools      = false,
) {
  require ::ceph::profile::client

  if $manage_repl_pools {
    create_resources(ceph::pool, lookup('profile::storage::cephpool::pools', Hash, 'first', {}))
  }

  if $manage_ec_pools {
    create_resources(profile::storage::ceph_ecpool, lookup('profile::storage::ceph_ecpool::ec_pools', Hash, 'first'))
  }

  if $manage_cephpool_params {
    create_resources(profile::storage::ceph_crushrules, lookup('profile::storage::ceph_crushrules::rules', Hash, 'first'))
    create_resources(profile::storage::cephpool_params, lookup('profile::storage::cephpool_params::pools', Hash, 'first'))
  }
}
