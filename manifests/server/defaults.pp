class ldap::server::defaults inherits ldap::defaults {
  case $operatingsystem {
    'ubuntu': {
      $default_packages     = [
        'slapd',
        'ldap-utils',
        'ldapscripts',
      ]
      $os_services     = [
        'slapd'
      ]
      $os_conf_files   = [
        'present:absent:root:root:0644:/etc/default/slapd',
        'present:absent:root:root:0644:/etc/ldap/ldap.conf',
      ]
      $os_ldap_conf_dir = "/etc/ldap/slapd.d"
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }

  $prune                   = $os_prune ? {
    ''      => 'false',
    default => $os_prune
  }
  $owner                   = $os_owner
  $group                   = $os_group
  $packages                = $os_packages
  $services                = $os_services
  $ldif_dir                = $os_ldif_dir ? {
    ''      => '/var/lib/puppet/state/modules/ldap',
    default => $os_ldif_dir
  }
  $directory_base          = $os_directory_base ? {
    ''      => '/var/lib/ldap',
    default => $os_directory_base
  }
  $password                = $os_password ? {
    ''      => $uniqueid,
    default => $os_password
  }
  $directories             = $os_directories
  $ArgsFile                = $os_ArgsFile
  $LdapLogLevel            = $os_LdapLogLevel ? {
    ''      => 'none',
    default => $os_LdapLogLevel
  }
  $PidFile                 = $os_PidFile
  $ToolThreads             = $os_ToolThreads
  $TLSVerifyClient         = $os_TLSVerifyClient ? {
    ''      => 'never',
    default => $os_TLSVerifyClient
  }
  $TLSCACertificateFile    = $os_TLSCACertificateFile
  $TLSCACertificatePath    = $os_TLSCACertificatePath
  $TLSCertificateFile      = $os_TLSCertificateFile ? {
    ''      => '/etc/ldap-server.crt',
    default => $os_TLSCertificateFile
  }
  $TLSCertificateKeyFile   = $os_TLSCertificateKeyFile ? {
    ''      => '/etc/ldap-server.key',
    default => $os_TLSCertificateKeyFile
  }
  $TLSCipherSuite          = $os_TLSCipherSuite
  $TLSRandFile             = $os_TLSRandFile
  $TLSEphemeralDHParamFile = $os_TLSEphemeralDHParamFile
  $conf_files              = $os_conf_files ? {
    ''      => '',
    default => $os_conf_files
  }
  $ldap_conf_dir           = $os_ldap_conf_dir

  $cert_country      = 'US'
  $cert_state        = 'California'
  $cert_city         = 'Culver City'
  $cert_organization = 'N/A'
  $cert_department   = 'N/A'
  $cert_domain       = $fqdn
  $cert_email        = "root@${fqdn}"
}
