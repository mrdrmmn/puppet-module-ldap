class ldap::client::defaults {
  case $operatingsystem {
    'ubuntu': {
      $os_packages  = [
        'ldap-auth-client',
        'nss-updatedb',
        'libnss-db',
        'libpam-ccreds',
      ]
      $os_conf_files = [
        'present:present:root:root:0644:/etc/nsswitch.conf',
        'present:absent:root:root:0644:/etc/ldap.conf',
        'present:absent:root:root:0600:/etc/ldap.secret',
      ]
      $os_nss_initgroups_ignoreusers = [
        'root',
        'openldap',
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }

  $packages                   = $os_packages
  $password                   = $os_password ? {
    ''      => $uniqueid,
    default => $os_password
  }
  $basedn                     = $os_basedn ? {
    ''      => 'unset',
    default => $os_basedn
  }
  $rootdn                     = $os_rootdn ? {
    ''      => 'unset',
    default => $os_rootdn
  }
  $search_timelimit           = $os_search_timelimit ? {
    ''      => 15,
    default => $os_search_timelimit
  }
  $bind_timelimit             = $os_bind_timelimit ? {
    ''      => 15,
    default => $os_bind_timelimit
  }
  $bind_policy                = $os_bind_policy ? {
    ''      => 'soft',
    default => $os_bind_policy
  }
  $ldap_uri                   = $os_ldap_uri ? {
    ''      => 'ldap:///',
    default => $os_ldap_uri
  }
  $ldap_version               = $os_ldap_version ? {
    ''      => 3,
    default => $os_ldap_version
  }
  $port                       = $os_port ? {
    ''      => 389,
    default => $os_port
  } 
  $pam_min_uid                = $os_pam_min_uid ? {
    ''      => 1000,
    default => $os_pam_min_uid
  } 
  $pam_max_uid                = $os_pam_max_uid ? {
    ''      => 1000,
    default => $os_pam_max_uid
  } 
  $ssl_mode                   = $os_ssl_mode ? {
    ''      => 'start_tls',
    default => $os_ssl_mode
  } 
  $tls_checkpeer              = $os_tls_checkpeer ? {
    ''      => 'no',
    default => $os_tls_checkpeer
  }
  $tls_ciphers                = $os_tls_ciphers ? {
    ''      => 'TLSv1',
    default => $os_tls_ciphers
  }
  $nss_initgroups_ignoreusers = $os_nss_initgroups_ignoreusers ? {
    ''      => [ 'root' ],
    default => $os_nss_initgroups_ignoreusers
  }
  $conf_files                 = $os_conf_files
}
