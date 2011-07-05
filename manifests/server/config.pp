class ldap::server::config {
  case $operatingsystem {
    'ubuntu': {
      $path         = '/var/lib/ldap'
      $system_user  = 'openldap'
      $system_group = 'openldap'
      $packages     = [
        'slapd',
        'ldap-utils'
      ]
      $services     = [
        'slapd'
      ]
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }

  $ArgsFile                = '/var/run/slapd/slapd.args'
  $LogLevel                = 'none'
  $PidFile                 = '/var/run/slapd/slapd.pid'
  $ToolThreads             = '1'
  $TLSVerifyClient         = ''
  $TLSCACertificateFile    = ''
  $TLSCACertificatePath    = ''
  $TLSCertificateFile      = ''
  $TLSCertificateKeyFile   = ''
  $TLSCipherSuite          = ''
  $TLSRandFile             = ''
  $TLSEphemeralDHParamFile = ''
}
