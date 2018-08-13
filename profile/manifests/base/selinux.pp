#
# This class enables selinux, add packages and rules for selinux
#
class profile::base::selinux(
  $manage_selinux = false,
  $packages = ['setroubleshoot-server', 'setools-console', 'policycoreutils']
) {

  if $manage_selinux {
    warning('NORCAMS: selinux now are enforcing!')
    include ::selinux

    $ports = lookup('profile::base::selinux::ports', Hash, 'deep', {})
    $boolean = lookup('profile::base::selinux::boolean', Hash, 'deep', {})

    create_resources('selinux::port', $ports)
    create_resources('selinux::boolean', $boolean)

    package { $packages:
      ensure => installed
    }

  }

}
