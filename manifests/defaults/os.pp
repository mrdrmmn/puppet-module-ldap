class ldap::defaults::os inherits ldap::defaults {
  # Set default values based on system type.
  case $operatingsystem {
    'ubuntu','debian': {
      $user  = 'openldap'
      $group = 'openldap'
      $ssl_cipher_suite = 'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'
    }
    'linux','centos': {
      $user  = 'ldap'
      $group = 'ldap'
      $ssl_cert_file         = '/etc/openldap/ssl.crt'
      $ssl_key_file          = '/etc/openldap/ssl.key'
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
