# Class: ldap::server::directory
#
# This module manages ldap directories.
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
define ldap::server::directory (
  $ensure         = $ldap::server::config::ensure,
  $user           = $ldap::server::config::user,
  $group          = $ldap::server::config::group,
  $root_cn        = $ldap::server::config::root_cn,
  $password       = $ldap::server::config::password,
  $directory_base = $ldap::server::config::directory_base,
  $ldif_dir       = $ldap::server::config::ldif_dir
) {
  include ldap::anchor
  
  # Grab the base dn of our directory from the name of this define.
  $base_dn = $name

  $directory_path                = "${directory_base}/${base_dn}"
  $directory_init_file           = "${ldif_dir}/${base_dn}-init.ldif"
  $exec_directory_initialize     = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${directory_init_file}'"
  $exec_directory_is_initialized = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b cn=config -s sub '(&(objectClass=olcDatabaseConfig)(olcSuffix=${base_dn}))' dn`\""
  $directory_conf_file           = "${ldif_dir}/${base_dn}-conf.ldif"
  $exec_directory_configure      = "ldapadd -Z -y /etc/ldap.secret -D 'cn=${root_cn},${base_dn}' -f '${directory_conf_file}'"
  $exec_directory_is_configured  = "test -n \"`ldapsearch -Z -y /etc/ldap.secret -D 'cn=${root_cn},${base_dn}' -LLL -s base 2>/dev/null`\""

  case $ensure {
    'present','installed': {
      ::directory{ $directory_path:
        owner   => $user,
        group   => $group,
        mode    => '0700',
        recurse => 'true',
        require => Anchor[ 'phase3' ],
        before  => Anchor[ 'phase4' ],
      }

      file{ $directory_init_file:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        content => template( 'ldap/server/directory-init.ldif' ),
        require => Anchor[ 'phase3' ],
        before  => Anchor[ 'phase4' ],
      }
      exec{ $exec_directory_initialize:
        path    => '/usr/bin',
        unless  => $exec_directory_is_initialized,
        require => Anchor[ 'phase4' ],
        before  => Anchor[ 'phase5' ],
      }

      file{ $directory_conf_file:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        content => template( 'ldap/server/directory-conf.ldif' ),
        require => Anchor[ 'phase3' ],
        before  => Anchor[ 'phase4' ],
      }
      exec{ $exec_directory_configure:
        path    => '/usr/bin',
        unless  => $exec_directory_is_configured,
        require => Exec[ $exec_directory_initialize ],
        before  => Anchor[ 'phase5' ],
      }
    }
    
    'absent','removed': {
    }
    default: {
      fail( 'ensure must be one of the following: present, installed, absent, removed' )
    }
  }
}
