class profile::dns::rndc_key (
  $name = {},
  $secret = {}
)
{
  file { "/etc/rndc-${name}.key":
    content      => template("${module_name}/dns/bind/rndc.key.erb"),
    notify       => Service['named'],
    mode         => '0640',
    owner        => 'named',
    group        => 'named',
    require      => Package['bind'],
  }
}
