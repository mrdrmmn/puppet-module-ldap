class ldap::utils::defaults::os inherits ldap::config {
  case $operatingsystem {
    'ubuntu','debian': {
      $packages     = [
        'ldap-utils',
        'ldapscripts',
      ]
      $conf_files   = [
        'present:absent:root:root:0644:utils/ldap.conf:/etc/ldap/ldap.conf',
        'present:absent:root:root:0644:utils/ldapscripts.conf:/etc/ldapscripts/ldapscripts.conf',
        'present:absent:root:root:0600:utils/ldapscripts.passwd:/etc/ldapscripts/ldapscripts.passwd',
      ]
    }
    'linux','centos','fedora': {
      $packages = [
        'openldap-clients',
      ]
      $conf_files   = [
        'present:absent:root:root:0644:utils/ldap.conf:/etc/openldap/ldap.conf',
      ]
    }

    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
