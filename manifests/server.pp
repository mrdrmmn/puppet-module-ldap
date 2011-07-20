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
  $ensure                  = $ldap::server::config::ensure
  $user                    = $ldap::server::config::user
  $group                   = $ldap::server::config::group
  $ldif_dir                = $ldap::server::config::ldif_dir
  $directory_base          = $ldap::server::config::directory_base
  $directories             = $ldap::server::config::directories
  $password                = $ldap::server::config::password
  $ArgsFile                = $ldap::server::config::args_file
  $LdapLogLevel            = $ldap::server::config::log_level
  $PidFile                 = $ldap::server::config::pid_file
  $ToolThreads             = $ldap::server::config::tool_threads
  $TLSVerifyClient         = $ldap::server::config::ssl_verify_certs
  $TLSCACertificateFile    = $ldap::server::config::ssl_cacert_file
  $TLSCACertificatePath    = $ldap::server::config::ssl_cacert_path
  $TLSCertificateFile      = $ldap::server::config::ssl_cert
  $TLSCertificateKeyFile   = $ldap::server::config::ssl_key
  $TLSCipherSuite          = $ldap::server::config::ssl_cipher_suite
  $TLSRandFile             = $ldap::server::config::ssl_rand_file
  $TLSEphemeralDHParamFile = $ldap::server::config::ssl_ephemeral_file
  $ldap_conf_dir           = $ldap::server::config::ldap_conf_dir
) {
  # Ensure our anchor points exist.
  include ldap::anchor

  # Load our defaults and generate our config values.
  $packages   = $ldap::server::config::packages
  $services   = $ldap::server::config::services
  $conf_files = $ldap::server::config::conf_files
  
  # Set up some commands we will ned to exec.
  $exec_remove_conf     = "find '${ldap_conf_dir}' -mindepth 1 -maxdepth 1 -exec rm -rf {} \\;"
  $exec_server_init     = "slapadd -F '${ldap_conf_dir}' -n 0 -l '${ldif_dir}/server-init.ldif'"
  $exec_server_conf     = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${ldif_dir}/server-conf.ldif'"
  $exec_ssl_cert_create = "echo '${ssl_cert_country}\n${ssl_cert_state}\n${ssl_cert_city}\n${ssl_cert_organization}\n${ssl_cert_department}\n${ssl_cert_domain}\n${ssl_cert_email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${ssl_key_file}' -out '${ssl_cert_file}'"
  $exec_ssl_cert_exists = "test -f '${config_TLSCertificateFile}' || test -f '${config_TLSCertificateKeyFile}'"

  case $ensure {
    'present','installed','latest': {
      if( $ldap_conf_dir != '' ) {
        # If this is triggers, it means that the slapd config has not
        # been initialized and it is safe to blow away and recreate
        #from scratch a bit later on.
        exec{ 'ldap-notify-if-uninitialized':
          command  => 'true',
          path     => '/bin:/usr/bin',
          before   => Anchor[ 'phase1' ],
          notify   => Exec[ 'ldap-server-init' ],
          unless   => "test -d '${ldap_conf_dir}'",
        }
      }

      if( ! defined( File[ $ssl_cert_file ] ) ) {
        exec{ $exec_ssl_cert_create:
          path    => '/bin:/usr/bin',
          before  => Anchor[ 'phase1' ],
          unless  => $exec_ssl_cert_exists,
        }
      }
      package{ $packages:
        ensure  => $ensure,
        require => Anchor[ 'phase1' ],
        before  => Anchor[ 'phase2' ],
      }
      service{ $services:
        ensure  => 'running',
        enable  => 'true',
        require => Anchor[ 'phase3' ],
        before  => Anchor[ 'phase4' ],
      }
      directory{ [ $ldif_dir, $directory_base ]:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0700',
        recurse => true,
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }

      file{ 'ldap-server-init':
        path    => "${config_ldif_dir}/server-init.ldif",
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0600',
        content => template( 'ldap/server/server-init.ldif' ),
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }
      exec{ 'ldap-server-init':
        command     => $exec_server_init,
        path        => '/usr/sbin:/usr/bin:/bin',
        user        => $user,
        group       => $group,
        require     => Anchor[ 'phase3' ],
        before      => Anchor[ 'phase4' ],
        onlyif      => $exec_remove_conf,
        notify      => Service[ $services ],
        refreshonly => 'true'
      }

      file{ 'ldap-server-conf':
        path    => "${ldif_dir}/server-conf.ldif",
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0600',
        content => template( 'ldap/server/server-conf.ldif' ),
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }
      exec{ 'ldap-server-conf':
        command     => $exec_server_conf,
        path        => '/usr/bin',
        before      => Anchor[ 'phase4' ],
        require     => Service[ $services ],
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
      package{ $packages:
        ensure => $ensure,
        require => Service[ $services ],
      }
      service{ $services:
        ensure => 'stopped',
        enable => 'false',
      }
      directory{ $ldif_dir:
        ensure  => 'absent',
        recurse => 'true',
        require => Service[ $services ],
      }
      if( $config_ensure == 'purged' ) {
        directory{ $directory_base:
          ensure  => 'absent',
          recurse => 'true',
          require => Service[ $services ]
        }
      }
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $conf_files:
    ensure => $ensure,
    require                        => Anchor[ 'phase2' ],
    before                         => Anchor[ 'phase3' ],
  }
}
