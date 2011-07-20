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
  $prune                   = '',
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
  $TLSEphemeralDHParamFile = '',
  $ldap_conf_dir           = '',
  $cert_country            = '',
  $cert_state              = '',
  $cert_city               = '',
  $cert_organization       = '',
  $cert_department         = '',
  $cert_domain             = '',
  $cert_email              = ''
) {
  # Ensure our anchor points exist.
  include ldap::anchor

  # Load our defaults and generate our config values.
  include ldap::server::defaults
  $config_ensure                  = $ensure ? {
    ''      => $ldap::server::defaults::ensure,
    default => $ensure
  }
  $config_prune                   = $prune ? {
    ''      => $ldap::server::defaults::prune,
    default => $prune
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
  notice( "PASSWORD: $config_password" )
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
  $config_ldap_conf_dir           = $ldap_conf_dir ? {
    ''      => $ldap::server::defaults::ldap_conf_dir,
    default => $ldap_conf_dir
  }
  $config_conf_files              = $conf_files ? {
    ''      => $ldap::server::defaults::conf_files,
    default => $conf_files
  }
  $config_cert_country            = $cert_country ? {
    ''      => $ldap::server::defaults::cert_country,
    default => $cert_country
  }
  $config_cert_state              = $cert_state ? {
    ''      => $ldap::server::defaults::cert_state,
    default => $cert_state
  }
  $config_cert_city               = $cert_city ? {
    ''      => $ldap::server::defaults::cert_city,
    default => $cert_city
  }
  $config_cert_organization       = $cert_organization ? {
    ''      => $ldap::server::defaults::cert_organization,
    default => $cert_organization
  }
  $config_cert_department         = $cert_department ? {
    ''      => $ldap::server::defaults::cert_department,
    default => $cert_department
  }
  $config_cert_domain             = $cert_domain ? {
    ''      => $ldap::server::defaults::cert_domain,
    default => $cert_domain
  }
  $config_cert_email              = $cert_email ? {
    ''      => $ldap::server::defaults::cert_email,
    default => $cert_email
  }
  
  # Set up some commands we will ned to exec.
  $exec_remove_conf     = "find '${config_ldap_conf_dir}' -mindepth 1 -maxdepth 1 -exec rm -rf {} \\;"
  $exec_server_init     = "slapadd -F '${config_ldap_conf_dir}' -n 0 -l '${config_ldif_dir}/server-init.ldif'"
  $exec_server_conf     = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${config_ldif_dir}/server-conf.ldif'"
  $exec_ssl_cert_create = "echo '${config_cert_country}\n${config_cert_state}\n${config_cert_city}\n${config_cert_organization}\n${config_cert_department}\n${config_cert_domain}\n${config_cert_email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${config_TLSCertificateKeyFile}' -out '${config_TLSCertificateFile}'"
  $exec_ssl_cert_exists = "test -f '${config_TLSCertificateFile}' || test -f '${config_TLSCertificateKeyFile}'"

  case $config_ensure {
    'present','installed','latest': {
      if( $config_ldap_conf_dir != '' ) {
        # If this is triggers, it means that the slapd config has not
        # been initialized and it is safe to blow away and recreate
        #from scratch a bit later on.
        exec{ 'ldap-notify-if-uninitialized':
          command  => 'true',
          path     => '/bin:/usr/bin',
          before   => Anchor[ 'phase1' ],
          notify   => Exec[ 'ldap-server-init' ],
          unless   => "test -d '${config_ldap_conf_dir}'",
        }
      }

      if( ! defined( File[ $config_TLSCertificateFile ] ) ) {
        exec{ $exec_ssl_cert_create:
          path    => '/bin:/usr/bin',
          before  => Anchor[ 'phase1' ],
          unless  => $exec_ssl_cert_exists,
        }
      }
      package{ $config_packages:
        ensure  => $config_ensure,
        require => Anchor[ 'phase1' ],
        before  => Anchor[ 'phase2' ],
      }
      service{ $config_services:
        ensure  => 'running',
        enable  => 'true',
        require => Anchor[ 'phase3' ],
        before  => Anchor[ 'phase4' ],
      }
      directory{ [ $config_ldif_dir, $config_directory_base ]:
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0700',
        recurse => true,
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }

      file{ 'ldap-server-init':
        path    => "${config_ldif_dir}/server-init.ldif",
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0600',
        content => template( 'ldap/server/server-init.ldif' ),
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }
      exec{ 'ldap-server-init':
        command     => $exec_server_init,
        path        => '/usr/sbin:/usr/bin:/bin',
        user        => $config_owner,
        group       => $config_group,
        require     => Anchor[ 'phase3' ],
        before      => Anchor[ 'phase4' ],
        onlyif      => $exec_remove_conf,
        notify      => Service[ $config_services ],
        refreshonly => 'true'
      }

      file{ 'ldap-server-conf':
        path    => "${config_ldif_dir}/server-conf.ldif",
        ensure  => 'present',
        owner   => $config_owner,
        group   => $config_group,
        mode    => '0600',
        content => template( 'ldap/server/server-conf.ldif' ),
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }
      exec{ 'ldap-server-conf':
        command     => $exec_server_conf,
        path        => '/usr/bin',
        before      => Anchor[ 'phase4' ],
        require     => Service[ $config_services ],
      }

      #ldap::server::directory{ $config_directories:
        #ensure         => 'present',
        #owner          => $config_owner,
        #group          => $config_group,
        #ldif_dir       => $config_ldif_dir,
        #directory_base => $config_directory_base,
      #}
    }

    'absent','removed','purged': {
      package{ $config_packages:
        ensure => $config_ensure,
        require => Service[ $config_services ],
      }
      service{ $config_services:
        ensure => 'stopped',
        enable => 'false',
      }
      directory{ $config_ldif_dir:
        ensure  => 'absent',
        recurse => 'true',
        require => Service[ $config_services ],
      }
      if( $config_ensure == 'purged' ) {
        directory{ $config_directory_base:
          ensure  => 'absent',
          recurse => 'true',
          require => Service[ $config_services ]
        }
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $config_conf_files:
    config_ensure                  => $config_ensure,
    config_basedn                  => $config_basedn,
    config_rootdn                  => $config_rootdn,
    config_password                => $config_password,
    config_ldap_uri                => $config_ldap_uri,
    config_search_timelimit        => $config_search_timelimit,
    config_bind_timelimit          => $config_bind_timelimit,
    config_bind_policy             => $config_bind_policy,
    config_packages                => $config_packages,
    config_ldap_version            => $config_ldap_version,
    config_port                    => $config_port,
    config_pam_min_uid             => $config_pam_min_uid,
    config_pam_max_uid             => $config_pam_max_uid,
    config_conf_files              => $config_conf_files,
    config_owner                   => $config_owner,
    config_group                   => $config_group,
    config_services                => $config_services,
    config_ldif_dir                => $config_ldif_dir,
    config_directory_base          => $config_directory_base,
    config_directories             => $config_directories,
    config_ArgsFile                => $config_ArgsFile,
    config_LdapLogLevel            => $config_LdapLogLevel,
    config_PidFile                 => $config_PidFile,
    config_ToolThreads             => $config_ToolThreads,
    config_TLSVerifyClient         => $config_TLSVerifyClient,
    config_TLSCACertificateFile    => $config_TLSCACertificateFile,
    config_TLSCACertificatePath    => $config_TLSCACertificatePath,
    config_TLSCertificateFile      => $config_TLSCertificateFile,
    config_TLSCertificateKeyFile   => $config_TLSCertificateKeyFile,
    config_TLSCipherSuite          => $config_TLSCipherSuite,
    config_TLSRandFile             => $config_TLSRandFile,
    config_TLSEphemeralDHParamFile => $config_TLSEphemeralDHParamFile,
    config_mode                    => 'server',
    require                        => Anchor[ 'phase2' ],
    before                         => Anchor[ 'phase3' ],
  }
}
