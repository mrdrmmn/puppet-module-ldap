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
define ldap::server (
  $ensure                  = '',
  $owner                   = '',
  $group                   = '',
  $packages                = '',
  $services                = '',
  $ldif_dir                = '',
  $directory_base          = '',
  $directories             = '',
  $password                = '',
  $ArgsFile                = '',
  $LdapLogLevel            = '',
  $PidFile                 = '',
  $ToolThreads             = '',
  $TLSVerifyClient         = '',
  $TLSCACertificateFile    = '',
  $TLSCACertificatePath    = '',
  $TLSCertificateFile      = '',
  $TLSCertificateKeyFile   = '',
  $TLSCipherSuite          = '',
  $TLSRandFile             = '',
  $TLSEphemeralDHParamFile = ''
) {
  # Ensure our anchor points exist.
  include ldap::anchor

  # Load our defaults and generate our config values.
  include ldap::server::defaults
  $config_ensure                  = $ensure ? {
    ''      => $ldap::server::defaults::ensure,
    default => $ensure
  }
  $config_owner                   = $owner ? {
    ''      => $ldap::server::defaults::owner,
    default => $owner
  }
  $config_group                   = $group ? {
    ''      => $ldap::server::defaults::group,
    default => $group
  }
  $config_packages                = $packages ? {
    ''      => $ldap::server::defaults::packages,
    default => $packages
  }
  $config_services                = $services ? {
    ''      => $ldap::server::defaults::services,
    default => $services
  }
  $config_ldif_dir                = $ldif_dir ? {
    ''      => $ldap::server::defaults::ldif_dir,
    default => $ldif_dir
  }
  $config_directory_base          = $directory_base ? {
    ''      => $ldap::server::defaults::directory_base,
    default => $directory_base
  }
  $config_directories             = $directories ? {
    ''      => $ldap::server::defaults::directories,
    default => $directories
  }
  $config_password                = $password ? {
    ''      => $ldap::server::defaults::password,
    default => $password
  }
  $config_ArgsFile                = $ArgsFile ? {
    ''      => $ldap::server::defaults::ArgsFile,
    default => $ArgsFile
  }
  $config_LdapLogLevel            = $LdapLogLevel ? {
    ''      => $ldap::server::defaults::LdapLogLevel,
    default => $LdapLogLevel
  }
  $config_PidFile                 = $PidFile ? {
    ''      => $ldap::server::defaults::PidFile,
    default => $PidFile
  }
  $config_ToolThreads             = $ToolThreads ? {
    ''      => $ldap::server::defaults::ToolThreads,
    default => $ToolThreads
  }
  $config_TLSVerifyClient         = $TLSVerifyClient ? {
    ''      => $ldap::server::defaults::TLSVerifyClient,
    default => $TLSVerifyClient
  }
  $config_TLSCACertificateFile    = $TLSCACertificateFile ? {
    ''      => $ldap::server::defaults::TLSCACertificateFile,
    default => $TLSCACertificateFile
  }
  $config_TLSCACertificatePath    = $TLSCACertificatePath ? {
    ''      => $ldap::server::defaults::TLSCACertificatePath,
    default => $TLSCACertificatePath
  }
  $config_TLSCertificateFile      = $TLSCertificateFile ? {
    ''      => $ldap::server::defaults::TLSCertificateFile,
    default => $TLSCertificateFile
  }
  $config_TLSCertificateKeyFile   = $TLSCertificateKeyFile ? {
    ''      => $ldap::server::defaults::TLSCertificateKeyFile,
    default => $TLSCertificateKeyFile
  }
  $config_TLSCipherSuite          = $TLSCiperSuite ? {
    ''      => $ldap::server::defaults::TLSCiperSuite,
    default => $TLSCiperSuite
  }
  $config_TLSRandFile             = $TLSRandFile ? {
    ''      => $ldap::server::defaults::TLSRandFile,
    default => $TLSRandFile
  }
  $config_TLSEphemeralDHParamFile = $TLSEphemeralDHParamFile ? {
    ''      => $ldap::server::defaults::TLSEphemeralDHParamFile,
    default => $TLSEphemeralDHParamFile
  }
  
  # Set up some commands we will ned to exec.
  $exec_server_config = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${config_ldif_dir}/ldap_config.ldif'"

  case $config_ensure {
    'present','installed','latest': {
      package{ $config_packages:
        ensure => $config_ensure,
        before => Anchor[ 'ldap::phase1' ]
      }
      service{ $config_services:
        ensure  => 'running',
        enable  => 'true',
        before  => Anchor[ 'ldap::phase1' ],
        require => Package[ $config_packages ],
      }
      directory{ [ $config_ldif_dir, $config_directory_base ]:
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0700',
        recurse => true,
        before  => Anchor[ 'ldap::phase1' ]
      }
      file{ 'ldap_config':
        path    => "${config_ldif_dir}/ldap_config.ldif",
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0700',
        content => template( 'ldap/ldap_config.ldif' ),
        before  => Anchor[ 'ldap::phase1' ],
      }
      exec{ $exec_server_config:
        path        => '/usr/bin',
        subscribe   => File[ 'ldap_config' ],
        notify      => Service[ $config_services ],
        before      => Anchor[ 'ldap::phase1' ],
        refreshonly => 'true'
      }
      ldap::server::directory{ $directories:
        ensure         => 'present',
        owner          => $config_owner,
        group          => $config_group,
        ldif_dir       => $config_ldif_dir,
        directory_base => $config_directory_base,
        require        => Anchor[ 'ldap::phase1' ]
      }
    }
    'absent','removed','purged': {
      package{ $config_packages:
        ensure => $config_ensure,
        before => Anchor[ 'ldap::phase1' ],
        require => Service[ $config_services ],
      }
      service{ $config_services:
        ensure  => 'stopped',
        enable  => 'false',
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }
}
include ldap::server::defaults
