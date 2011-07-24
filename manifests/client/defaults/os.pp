class ldap::client::defaults::os inherits ldap::client::defaults {
  case $operatingsystem {
    'ubuntu': {
      $packages  = [
        'ldap-auth-client',
        'nss-updatedb',
        'libnss-db',
        'libpam-ccreds',
      ]
      $conf_files = [
        'present:present:root:root:0644:client/nsswitch.conf:/etc/nsswitch.conf',
        'present:absent:root:root:0644:client/ldap.conf:/etc/ldap.conf',
        'present:absent:root:root:0600:client/ldap.secret:/etc/ldap.secret',
      ]
      $nss_initgroups_ignoreusers = [
        'root',
        'openldap',
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
