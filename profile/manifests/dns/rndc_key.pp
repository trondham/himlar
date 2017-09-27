class profile::dns::rndc_key 
{
#  $rndc = hiera_hash('profile::dns::rndc_keys', {})

#  key { $rndc[0]:
#    name   => $rndc[0],
#    secret => $rndc[1],
#  }

  hiera_hash('profile::dns::rndc_keys').each |String $rndc_key_name, String $rndc_key_secret| {
    file { "/etc/rndc-${rndc_key_name}.key":
      content      => template("${module_name}/dns/bind/rndc.key.erb"),
      notify       => Service['named'],
      mode         => '0640',
      owner        => 'named',
      group        => 'named',
      require      => Package['bind'],
    }
  }

}
