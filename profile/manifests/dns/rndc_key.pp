class profile::dns::rndc_key (
  $create_admin_key  = false,
  $create_mdns_key   = false,
  $rndc_secret_admin = {},
  $rndc_secret_mdns  = {}
)
{

  define profile::dns::rndc_key::create_keyfile ($name = {}, $secret = {}) {
    file { "/etc/rndc-${name}.key":
      content      => template("${module_name}/dns/bind/rndc.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }

  if $create_admin_key {
    create_resources('profile::dns::rndc_key::create_keyfile', [$name = 'admin', $secret = $rndc_secret_admin])
#    $this_rndc_name = 'admin'
#    $this_rndc_secret = $rndc_secret_admin
#    file { "/etc/rndc-admin.key":
#      content      => template("${module_name}/dns/bind/rndc.key.erb"),
#      notify       => Service['named'],
#      mode         => '0640',
#      owner        => 'named',
#      group        => 'named',
#      require      => Package['bind'],
#    }
  }

  if $create_mdns_key {
    create_resources('profile::dns::rndc_key::create_keyfile', [$name = 'mdns', $secret = $rndc_secret_mdns])
#    profile::dns::rndc_key::create_keyfile('mdns', $rndc_secret_mdns)
#    $this_rndc_name = 'mdns'
#    $this_rndc_secret = $rndc_secret_mdns
#    file { "/etc/rndc-mdns.key":
#      content      => template("${module_name}/dns/bind/rndc.key.erb"),
#      notify       => Service['named'],
#      mode         => '0640',
#      owner        => 'named',
#      group        => 'named',
#      require      => Package['bind'],
#    }
  }
}
