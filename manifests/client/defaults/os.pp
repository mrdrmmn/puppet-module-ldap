class ldap::client::defaults::os inherits ldap::client::defaults {
  case $operatingsystem {
    'ubuntu','debian': {
      $packages   = [
        'nss-updatedb',
        'libpam-ccreds',
        'libnss-db',
        'nslcd',
        'libpam-ldapd',
      ]
      $services   = [
        'nslcd',
      ]
      $conf_files = [
        'present:present:root:root:0644:client/nsswitch.conf:/etc/nsswitch.conf',
        'present:absent:root:root:0644:client/ldap.conf:/etc/ldap.conf',
        'present:absent:root:root:0600:client/ldap.secret:/etc/ldap.secret',
        'present:absent:root:nslcd:0640:client/nslcd.conf:/etc/nslcd.conf',
        #'present:present:root:root:0644:client/pam/common-password:/etc/pam.d/common-password',
      ]
      $nss_initgroups_ignoreusers = [
        'root',
        'openldap',
      ]
    }
    'linux','centos': {
      $packages = [
        'pam_ccreds',
        'nss_db',
        'nss-pam-ldapd',
      ]
      $services = [
        'nslcd',
      ]
      $conf_files = [
        'present:present:root:root:0644:client/nsswitch.conf:/etc/nsswitch.conf',
        'present:absent:root:root:0644:client/ldap.conf:/etc/pam_ldap.conf',
        'present:absent:root:root:0600:client/ldap.secret:/etc/ldap.secret',
        'present:absent:root:root:0600:client/nslcd.conf:/etc/nslcd.conf',
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
