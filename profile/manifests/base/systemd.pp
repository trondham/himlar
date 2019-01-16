# Class to reload systemd
class profile::base::systemd::daemon_reload {
  exec { '/usr/bin/systemctl daemon-reload':
    refreshonly => true,
  }
}
