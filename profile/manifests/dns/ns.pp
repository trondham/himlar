class profile::dns::ns (
  $my_transport_addr = {},
  $mdns_transport_addr = {},
  $ns1_transport_addr = {},
  $ns2_transport_addr = {},
  $ns1_public_addr = {},
  $ns2_public_addr = {},
  $master = {},
  $manage_firewall = {},
  $firewall_extras = {}
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
  
  package { 'bind':
    ensure => installed,
  }
  file { '/etc/rndc.conf':
    content      => template("${module_name}/dns/bind/rndc.conf.erb"),
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
    file { '/etc/named.vagrant.zone.conf':
      content      => template("${module_name}/dns/bind/master.vagrant.zone.conf.erb"),
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
    file { '/var/named/vagrant.iaas.intern.zone':
      content      => template("${module_name}/dns/bind/vagrant.iaas.intern.zone.erb"),
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
  }
  else {
    file { '/etc/named.vagrant.zone.conf':
      content      => template("${module_name}/dns/bind/slave.vagrant.zone.conf.erb"),
      mode         => '0640',
      owner        => 'root',
      group        => 'named',
      require      => Package['bind'],
    }
  }
  file { '/etc/named.conf':
    content      => template("${module_name}/dns/bind/named.conf.erb"),
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    validate_cmd => '/usr/sbin/named-checkconf %',
    require      => Package['bind'],
  }
  file { '/etc/rndc.key':
    source  => "puppet:///modules/${module_name}/dns/bind/rndc.key",
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
                   File['/var/named/vagrant.iaas.intern.zone'],
                   File['/etc/named.vagrant.zone.conf'],
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
                   File['/etc/named.vagrant.zone.conf'],
                   File['/etc/named.conf'] ],
    }
  }

  if $manage_firewall {
    profile::firewall::rule { '001 dns accept tcp':
      port   => 53,
      proto  => 'tcp'
    }
    profile::firewall::rule { '002 dns accept udp':
      port   => 53,
      proto  => 'udp'
    }
    profile::firewall::rule { '003 dns rndc accept tcp':
      port   => 953,
      proto  => 'tcp',
      extras => $firewall_extras
    }
  }
}

