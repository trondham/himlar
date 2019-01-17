# Class to reload systemd
class profile::base::systemd::daemon_reload {
  exec { '/bin/echo /usr/bin/systemctl daemon-reload':
    refreshonly => true,
  }
}
