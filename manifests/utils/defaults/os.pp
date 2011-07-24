class ldap::utils::defaults::os inherits ldap::config {
  case $operatingsystem {
    'ubuntu': {
      $packages     = [
        'ldap-utils',
        'ldapscripts',
      ]
      $conf_files   = [
        'present:absent:root:root:0644:utils/ldap.conf:/etc/ldap/ldap.conf',
      ]
    }

    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
