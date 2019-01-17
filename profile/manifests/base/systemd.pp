# Class to reload systemd
class profile::base::systemd {
  exec { 'systemctl_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}
