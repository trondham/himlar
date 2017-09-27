class profile::dns::rndc_key (
  $create_admin_key  = false,
  $create_mdns_key   = false,
  $rndc_secret_admin = $dns::rndc_secret_admin,
  $rndc_secret_mdns  = $dns::rndc_secret_mdns
)
{

  if $create_admin_key {
    $name = 'admin'
    $secret = $rndc_secret_admin
    file { "/etc/rndc-admin.key":
      content      => template("${module_name}/dns/bind/rndc.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }

  if $create_mdns_key {
    $name = 'mdns'
    $secret = $rndc_secret_mdns
    file { "/etc/rndc-mdns.key":
      content      => template("${module_name}/dns/bind/rndc.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }
}
