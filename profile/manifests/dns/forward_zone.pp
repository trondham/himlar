define profile::dns::forward_zone($zone, $filename) {
  $main_ns = $::profile::dns::ns::main_ns
  $mail    = $::profile::dns::ns::mail

  # Our name servers
  $ns_master = $::profile::dns::ns::ns_master
  $ns_slaves = lookup('profile::dns::ns::ns_slaves', Array, 'deep', [])

  file { "/var/named/${filename}":
    content => template("${module_name}/dns/bind/forward_zone.erb"),
    notify  => Service['named'],
    mode    => '0640',
    owner   => 'root',
    group   => 'named',
    replace => 'no',
    require => Package['bind'],
  }
}
