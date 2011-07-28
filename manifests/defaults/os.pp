class ldap::defaults::os inherits ldap::defaults {
  # Set default values based on system type.
  case $operatingsystem {
    'ubuntu': {
      $ssl_cipher_suite = 'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
