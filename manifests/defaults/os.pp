class ldap::defaults::os inherits ldap::defaults {
  # Set default values based on system type.
  case $operatingsystem {
    'ubuntu': {
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
