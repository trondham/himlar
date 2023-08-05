#
# This is include from profile::base::physical
#
class profile::monitoring::physical::power(
  String $http_proxy,
  String $statsd_server,
  Boolean $enable = false,
  String $statsd_port = '8125'
) {

  if $enable {
    $bmc_username = lookup('bmc_username', String, 'first', '')
    $bmc_password = lookup("bmc_password_${::location}", String, 'first', '')

    $bmc_network  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\2',) - 1
    $bmc_address  = regsubst($::ipaddress_trp1, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$',"\\1.${bmc_network}.\\3.\\4",)

    file { 'power_metric.sh':
      ensure  => file,
      path    => '/usr/local/bin/power_metric.sh',
      content => template("${module_name}/monitoring/sensu/power_metric.sh.erb"),
      mode    => '0755',
    }
  }

}
