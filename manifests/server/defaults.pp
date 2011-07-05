class ldap::server::defaults {
  case $operatingsystem {
    'ubuntu': {
      $os_owner        = 'openldap'
      $os_group        = 'openldap'
      $os_packages     = [
        'slapd',
        'ldap-utils'
      ]
      $os_services     = [
        'slapd'
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
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
  $password                = $os_password
  $directories             = $os_directories
  $ArgsFile                = $os_ArgsFile
  $LdapLogLevel            = $os_LdapLogLevel
  $PidFile                 = $os_PidFile
  $ToolThreads             = $os_ToolThreads
  $TLSVerifyClient         = $os_TLSVerifyClient
  $TLSCACertificateFile    = $os_TLSCACertificateFile
  $TLSCACertificatePath    = $os_TLSCACertificatePath
  $TLSCertificateFile      = $os_TLSCertificateFile
  $TLSCertificateKeyFile   = $os_TLSCertificateKeyFile
  $TLSCipherSuite          = $os_TLSCipherSuite
  $TLSRandFile             = $os_TLSRandFile
  $TLSEphemeralDHParamFile = $os_TLSEphemeralDHParamFile
}
