# Class to reload systemd
class profile::base::systemd::daemon_reload {
  exec { 'puppet_sucks':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
