class profile::dns::rndc_key (
  $rndc_key_name   = $profile::dns::rndc_key_name,
  $rndc_key_secret = $profile::dns::rndc_key_secret
)
{
  file { "/etc/rndc-${rndc_key_name}.key":
    content      => template("${module_name}/dns/bind/rndc.key.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }
}
