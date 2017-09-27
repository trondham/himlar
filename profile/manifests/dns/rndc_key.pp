class profile::dns::rndc_key (
  $create_admin_key  = false,
  $create_mdns_key   = false,
  $rndc_secret_admin = $profile::dns::rndc_key::rndc_secret_admin,
  $rndc_secret_mdns  = $profile::dns::rndc_key::rndc_secret_mdns
)
{

  if $create_admin_key {
    file { "/etc/rndc-admin.key":
      content      => template("${module_name}/dns/bind/rndc-admin.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }

  if $create_mdns_key {
    file { "/etc/rndc-mdns.key":
      content      => template("${module_name}/dns/bind/rndc-mdns.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }
}
