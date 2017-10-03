class profile::dns::ns (
  $my_mgmt_addr = {},
  $my_transport_addr = {},
  #$mdns_transport_addr = {},
  $admin_mgmt_addr = {},
  $ns1_transport_addr = {},
  $ns2_transport_addr = {},
  $ns1_public_addr = {},
  $master = {},
  $manage_firewall = {},
  $firewall_extras = {},
  $internal_zone = {}
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

  $reverse_zones = hiera_hash('profile::dns::ns::ptr_zones', {})

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
    file { "/var/named/${internal_zone}.zone":
      content      => template("${module_name}/dns/bind/${internal_zone}.zone.erb"),
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

  if $master {
    service { 'named':
      ensure => running,
      enable => true,
      require => [ File['/etc/rndc.conf'],
                   File['/var/named'],
                   File["/var/named/${internal_zone}.zone"],
                   File['/etc/named.conf'] ],
    }
  }
  else {
    service { 'named':
      ensure => running,
      enable => true,
      require => [ File['/etc/rndc.conf'],
                   File['/var/named'],
                   File['/etc/named.conf'] ],
    }
  }

  define reverse_zone($cidr, $origin, $filename) {
    $internal_zone = $profile::dns::ns::internal_zone
    file { "/var/named/$filename":
      content      => template("${module_name}/dns/bind/reverse_zone.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
  }
  if $master {
    create_resources('reverse_zone', $reverse_zones)
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
