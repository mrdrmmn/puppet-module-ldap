class ldap::server::defaults::os inherits ldap::server::defaults {
  case $operatingsystem {
    'ubuntu': {
      $packages     = [
        'slapd',
      ]
      $services     = [
        'slapd'
      ]
      $conf_files   = [
        'present:absent:root:root:0644:server/etc-default-slapd:/etc/default/slapd',
      ]
      $ldap_conf_dir = "/etc/ldap/slapd.d"
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
