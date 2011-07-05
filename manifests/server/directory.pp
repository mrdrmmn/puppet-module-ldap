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
  $ensure         = '',
  $owner          = '',
  $group          = '',
  $user           = '',
  $ldif_dir       = '',
  $directory_base = '',
  $password       = '',
  $basedn         = '',
  $rootdn         = ''
) {
  include ldap::anchor

  include ldap::server::defaults
  $config_ensure         = $ensure ? {
    ''      => $ldap::server::defaults::ensure,
    default => $ensure
  }
  $config_owner          = $owner ? {
    ''      => $ldap::server::defaults::owner,
    default => $owner
  }
  $config_group          = $group ? {
    ''      =>$ldap::server::defaults::group,
    default => $group
  }
  $config_ldif_dir       = $ldif_dir ? {
    ''      =>$ldap::server::defaults::ldif_dir,
    default => $ldif_dir
  }
  $config_directory_base = $directory_base ? {
    ''      => $ldap::server::defaults::directory_base,
    default => $directory_base
  }
  $config_password       = $password ? {
    ''      => $ldap::server::defaults::password,
    default => $password
  }

  # Manipulate our variables as needed.
  $config_basedn = $basedn ? {
    ''      => $name,
    default => $basedn
  }
  $config_rootdn = $rootdn ? {
    ''      => "cn=admin,${config_basedn}",
    default => $rootdn
  }
  $directory_path                = "${config_directory_base}/${config_basedn}"
  $directory_conf_file           = "${config_ldif_dir}/${config_basedn}-conf.ldif"
  $directory_init_file           = "${config_ldif_dir}/${config_basedn}-init.ldif"
  $exec_directory_configure      = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${directory_conf_file}'"
  $exec_directory_is_configured  = "ldapsearch -Y EXTERNAL -H ldapi:/// -b 'cn=config' 'olcSuffix=${config_basedn}'"
  $exec_directory_initialize     = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${directory_init_file}'"
  $exec_directory_is_initialized = "ldapsearch -Y EXTERNAL -H ldapi:/// -b '${config_basedn}' -s base"

  case $config_ensure {
    'present','installed': {
      ::directory{ "$directory_path":
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0700',
        recurse => 'true';
      }
      file{ $directory_conf_file:
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        content => template( 'ldap/directory-conf.ldif' );
      }
      file{ $directory_init_file:
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        content => template( 'ldap/directory-init.ldif' );
      }
      exec{ $exec_directory_configure:
        path        => '/usr/bin',
        unless      => $exec_directory_is_initialized,
        require     => File[ $directory_conf_file ],
        refreshonly => 'true'
      }
      exec{ $exec_directory_initialize:
        path    => '/usr/bin',
        unless  => $exec_directory_is_initialized,
        require => [
          File[ $directory_init_file ],
          Exec[ $exec_directory_configure ]
        ];
      }

    }
    'absent','removed': {
    }
    default: {
      fail( 'ensure must be one of the following: present, installed, absent, removed' )
    }
  }
}
