# Class: ldap
#
# This module manages ldap
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define ldap::client (
  $ensure   = '',
  $user     = '',
  $path     = '',
  $basedn   = '',
  $password = ''
) {
  # Load our configuration.
  include ldap::client::config
  $packages = $ldap::client::config::packages
  $services = $ldap::client::config::services

  # Manipulate our variables as needed.
  case $basedn {
    '': { $ldap_basedn = $name }
    default: { $ldap_basedn = $basedn }
  }
  case $path {
    '': { $ldap_path = "${ldap::server::config::path}/${ldap_basedn}" }
    default: { $ldap_path = $path }
  }
  alert( "ldap_basedn = $ldap_basedn" )
  alert( "ldap_path = $ldap_path" )

  case $ensure {
    'present','installed': {
      if( ! defined( Ldap::Bouy[ 'ldap::client::package' ] ) ) {
        ldap::client::package{ $packages:
          ensure => 'installed'
        }
        ldap::bouy{ 'ldap::client::package': }
      }
      if( ! defined( Ldap::Bouy[ 'ldap::client::service' ] ) ) {
        ldap::client::service{ $services:
          ensure  => 'running',
          enable  => 'true',
          require => Ldap::Bouy[ 'ldap::client::package' ]
        }
        ldap::bouy{ 'ldap::client::service': }
      }
    }
    'absent','removed': {
    }
    default: {
      fail( 'ensure must be one of the following: present, installed, absent, removed' )
    }
  }
}
