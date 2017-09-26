class profile::dns::ns (
  $my_transport_addr = {},
  #$mdns_transport_addr = {},
  $ns1_transport_addr = {},
  $ns2_transport_addr = {},
  $ns1_public_addr = {},
  $ns2_public_addr = {},
  $master = {},
  $manage_firewall = {},
  $firewall_extras = {},
  $internal_zone = {},
  $named_zone_records = {}
)
{
  class { selinux:
    mode => 'enforcing',
    type => 'targeted',
  }
  selinux::boolean { 'named_write_master_zones':
    ensure     => 'on',
    persistent => true,
  }

  # Fetch dns records
  $dns_records = hiera_hash('profile::network::services::dns_records', {})
  # Create temp variable
  $named_zone_records = join_keys_to_values($dns_records['A'], ' IN A ')

  package { 'bind':
    ensure => installed,
  }
  file { '/etc/rndc.conf':
    content      => template("${module_name}/dns/bind/rndc.conf.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }
  file { '/var/named':
    ensure       => directory,
    mode         => '0770',
    owner        => 'root',
    group        => 'named',
    require      => Package['bind'],
  }
  if $master {
    file { "/etc/named.${internal_zone}.conf":
      content      => template("${module_name}/dns/bind/master.internal.conf.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
    file { "/var/named/${internal_zone}.zone":
      content      => template("${module_name}/dns/bind/${internal_zone}.zone.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
  }
  else {
    file { "/etc/named.${internal_zone}.conf":
      content      => template("${module_name}/dns/bind/slave.internal.conf.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
  }
  file { '/etc/named.conf':
    content      => template("${module_name}/dns/bind/named.conf.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    validate_cmd => '/usr/sbin/named-checkconf %',
    require      => Package['bind'],
  }
  file { '/etc/rndc.key':
    source  => "puppet:///modules/${module_name}/dns/bind/rndc.key",
    notify       => Service['named'],
    ensure  => file,
    mode    => '0600',
    owner   => 'named',
    group   => 'named',
    require => Package['bind'],
  }

  if $master {
    service { 'named':
      ensure => running,
      enable => true,
      require => [ File['/etc/rndc.key'],
                   File['/etc/rndc.conf'],
                   File['/var/named'],
                   File["/var/named/${internal_zone}.zone"],
                   File["/etc/named.${internal_zone}.conf"],
                   File['/etc/named.conf'] ],
    }
  }
  else {
    service { 'named':
      ensure => running,
      enable => true,
      require => [ File['/etc/rndc.key'],
                   File['/etc/rndc.conf'],
                   File['/var/named'],
                   File["/etc/named.${internal_zone}.conf"],
                   File['/etc/named.conf'] ],
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '001 dns incoming tcp':
      port   => 53,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 dns incoming udp':
      port   => 53,
      proto  => 'udp'
    }
    profile::firewall::rule { '003 rndc incoming - bind only':
      port   => 953,
      proto  => 'tcp',
      extras => $firewall_extras
    }
  }
}
