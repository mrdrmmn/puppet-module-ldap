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
  $ensure                = $ldap::server::config::ensure,
  $user                  = $ldap::server::config::user,
  $group                 = $ldap::server::config::group,
  $root_cn               = $ldap::server::config::root_cn,
  $password              = $ldap::server::config::password,
  $ldif_dir              = $ldap::server::config::ldif_dir,
  $directory_base        = $ldap::server::config::directory_base,
  $directories           = $ldap::server::config::directories,
  $args_file             = $ldap::server::config::args_file,
  $log_level             = $ldap::server::config::log_level,
  $pid_file              = $ldap::server::config::pid_file,
  $tool_threads          = $ldap::server::config::tool_threads,
  $ssl_verify_certs      = $ldap::server::config::ssl_verify_certs,
  $ssl_cacert_file       = $ldap::server::config::ssl_cacert_file,
  $ssl_cacert_path       = $ldap::server::config::ssl_cacert_path,
  $ssl_cert_file         = $ldap::server::config::ssl_cert_file,
  $ssl_key_file          = $ldap::server::config::ssl_key_file,
  $ssl_cipher_suite      = $ldap::server::config::ssl_cipher_suite,
  $ssl_rand_file         = $ldap::server::config::ssl_rand_file,
  $ssl_ephemeral_file    = $ldap::server::config::ssl_ephemeral_file,
  $ssl_minimum           = $ldap::server::config::ssl_minimum,
  $sasl_minssf           = $ldap::server::config::sasl_minssf,
  $sasl_maxssf           = $ldap::server::config::sasl_maxssf,
  $ldap_conf_dir         = $ldap::server::config::ldap_conf_dir,
  $protocols             = $ldap::server::config::protocols,
  $ssl_cert_country      = $ldap::server::config::ssl_cert_country,
  $ssl_cert_state        = $ldap::server::config::ssl_cert_state,
  $ssl_cert_city         = $ldap::server::config::ssl_cert_city,
  $ssl_cert_organization = $ldap::server::config::ssl_cert_organization,
  $ssl_cert_department   = $ldap::server::config::ssl_cert_department,
  $ssl_cert_domain       = $ldap::server::config::ssl_cert_domain,
  $ssl_cert_email        = $ldap::server::config::ssl_cert_email
) {
  # Ensure our anchor points exist.
  include ldap::anchor

  # Load our defaults and generate our config values.
  $packages   = $ldap::server::config::packages
  $services   = $ldap::server::config::services
  $conf_files = $ldap::server::config::conf_files
  $schemas    = $ldap::server::config::schemas
  
  # Set up some commands we will need to exec.
  $exec_remove_conf     = "find '${ldap_conf_dir}' -mindepth 1 -maxdepth 1 -exec rm -rf {} \\;"
  $exec_server_init     = "slapadd -F '${ldap_conf_dir}' -n 0 -l '${ldif_dir}/server-init.ldif'"
  $exec_load_schema     = "slapadd -F '${ldap_conf_dir}' -n 0 -l '${ldif_dir}/schema.ldif'"
  $exec_server_conf     = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${ldif_dir}/server-conf.ldif'"
  $exec_ssl_cert_create = "echo '${ssl_cert_country}\n${ssl_cert_state}\n${ssl_cert_city}\n${ssl_cert_organization}\n${ssl_cert_department}\n${ssl_cert_domain}\n${ssl_cert_email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${ssl_key_file}' -out '${ssl_cert_file}'"
  $exec_ssl_cert_exists = "test -s '${ssl_cert_file}' || test -s '${ssl_key_file}'"

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
        file{ $ssl_cert_file:
          ensure  => 'file',
          owner   => $user,
          group   => $group,
          mode    => $mode,
          notify  => Exec[ 'ldap-ssl-cert-create' ],
        }
      }
      if( ! defined( File[ $ssl_key_file ] ) ) {
        file{ $ssl_key_file:
          ensure  => 'file',
          owner   => $user,
          group   => $group,
          mode    => $mode,
          notify  => Exec[ 'ldap-ssl-cert-create' ],
        }
      }
      exec{ 'ldap-ssl-cert-create':
        command     => $exec_ssl_cert_create,
        path        => '/bin:/usr/bin',
        before      => Anchor[ 'phase1' ],
        unless      => $exec_ssl_cert_exists,
        refreshonly => 'true'
      }

      include ldap::utils::config
      if( ! defined( Ldap::Utils[ 'ldap-utils' ] ) ) {
        ldap::utils{ 'ldap-utils':
          ensure   => 'present',
          base_dn  => inline_template( '<%= directories.at(0) %>' ),
          root_cn  => $root_cn,
          password => $password,
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
        path    => "${ldif_dir}/server-init.ldif",
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
        notify      => Exec[ 'ldap-load-schema' ],
        refreshonly => 'true'
      }

      file{ 'ldap-load-schema':
        path    => "${ldif_dir}/schema.ldif",
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0600',
        content => template( 'ldap/server/schema.ldif' ),
        require => Anchor[ 'phase2' ],
        before  => Anchor[ 'phase3' ],
      }
      exec{ 'ldap-load-schema':
        command     => $exec_load_schema,
        path        => '/usr/sbin:/usr/bin:/bin',
        user        => $user,
        group       => $group,
        require     => Anchor[ 'phase3' ],
        before      => Anchor[ 'phase4' ],
        notify      => [
          Service[ $services ],
          Exec[ 'ldap-server-conf' ],
        ],
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
        notify      => [
          Exec[ 'ldap-server-conf' ],
        ],
      }
      exec{ 'ldap-server-conf':
        command     => $exec_server_conf,
        path        => '/usr/bin',
        before      => Anchor[ 'phase4' ],
        require     => Service[ $services ],
        refreshonly => 'true',
      }

      ldap::server::directory{ $directories:
        ensure         => 'present',
        user           => $user,
        group          => $group,
        root_cn        => $root_cn,
        password       => $password,
        directory_base => $directory_base,
        ldif_dir       => $ldif_dir,
      }
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
        directory{ [ $directory_base, $ldap_conf_dir ]:
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
