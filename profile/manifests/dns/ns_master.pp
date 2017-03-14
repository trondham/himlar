class profile::dns::ns_master (
  $run_rndc_confgen = false,
)
{
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
  file { '/etc/named.conf':
    content      => template("${module_name}/dns/bind/named.conf.erb"),
    mode         => '0640',
    owner        => 'root',
    group        => 'named',
    validate_cmd => '/usr/sbin/named-checkconf %',
    require      => Package['bind'],
  }
  file { '/var/named':
    ensure       => directory,
    mode         => '0770',
    owner        => 'root',
    group        => 'named',
    require      => Package['bind'],
  }
  exec { '/usr/sbin/setsebool -P named_write_master_zones on':
    unless  => "/usr/sbin/getsebool named_write_master_zones | /usr/bin/egrep -q 'on$'",
    require => Package['bind'],
  }

  if $run_rndc_confgen {
    exec { '/usr/sbin/rndc-confgen -a':
      creates => '/etc/rndc.key',
      require => Package['bind'],
    }
    file { '/etc/rndc.key':
      ensure  => file,
      mode    => '0600',
      owner   => 'named',
      group   => 'named',
      require => Exec['/usr/sbin/rndc-confgen -a'],
    }
  }
  else {
    file { '/etc/rndc.key':
      source  => "puppet:///modules/${module_name}/dns/bind/rndc.key",
      ensure  => file,
      mode    => '0600',
      owner   => 'named',
      group   => 'named',
      require => Package['bind'],
    }
  }

  service { 'named':
    ensure => running,
    enable => true,
    require => [ File['/etc/rndc.key'], File['/etc/rndc.conf'],
                 File['/etc/named.conf'], File['/var/named'],
                 Exec['/usr/sbin/setsebool -P named_write_master_zones on'] ],
  }
}

