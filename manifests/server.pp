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
  $server_nodes          = $ldap::server::config::server_nodes,
  $client_nodes          = $ldap::server::config::client_nodes,
  $utils_nodes           = $ldap::server::config::utils_nodes,
  $user                  = $ldap::server::config::user,
  $group                 = $ldap::server::config::group,
  $base_dn               = $ldap::server::config::base_dn,
  $password              = $ldap::server::config::password,
  $protocols             = $ldap::server::config::protocols,
  $protocol              = $ldap::server::config::protocol,
  $ldap_version          = $ldap::server::config::ldap_version,
  $server_addr           = $ldap::server::config::server_addr,
  $port                  = $ldap::server::config::port,
  $ssl_port              = $ldap::server::config::ssl_port,
  $search_timelimit      = $ldap::server::config::search_timelimit,
  $bind_timelimit        = $ldap::server::config::bind_timelimit,
  $idle_timelimit        = $ldap::server::config::idle_timelimit,
  $ldif_dir              = $ldap::server::config::ldif_dir,
  $ldap_conf_dir         = $ldap::server::config::ldap_conf_dir,
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
  $ssl_mode              = $ldap::server::config::ssl_mode,
  $sasl_minssf           = $ldap::server::config::sasl_minssf,
  $sasl_maxssf           = $ldap::server::config::sasl_maxssf,
  $ssl_cert_country      = $ldap::server::config::ssl_cert_country,
  $ssl_cert_state        = $ldap::server::config::ssl_cert_state,
  $ssl_cert_city         = $ldap::server::config::ssl_cert_city,
  $ssl_cert_organization = $ldap::server::config::ssl_cert_organization,
  $ssl_cert_department   = $ldap::server::config::ssl_cert_department,
  $ssl_cert_domain       = $ldap::server::config::ssl_cert_domain,
  $ssl_cert_email        = $ldap::server::config::ssl_cert_email,
  $bind_policy           = $ldap::server::config::bind_policy,
  $pam_min_uid           = $ldap::server::config::pam_min_uid,
  $pam_max_uid           = $ldap::server::config::pam_max_uid,
  $exec_path             = $ldap::server::config::exec_path,
  $admin_directory       = $ldap::server::config::admin_directory
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Ldap::Dummy[ 'ldap::server' ] ) ) {
    fail( 'The "ldap::server" define has already been called previously in your manifest!' )
  }
  ldap::dummy{ 'ldap::server': }

  # Load our defaults and generate our config values.
  $packages   = $ldap::server::config::packages
  $services   = $ldap::server::config::services
  $conf_files = $ldap::server::config::conf_files
  $schemas    = $ldap::server::config::schemas
  
  # Set up some commands we will need to exec.
  $exec_remove_conf     = "rm -rf '${ldap_conf_dir}'"
  $exec_server_init     = "slapadd -F '${ldap_conf_dir}' -n 0 -l '${ldif_dir}/server-init.ldif'"
  $exec_server_populate = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${ldif_dir}/server-populate.ldif'"
  $exec_server_conf     = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${ldif_dir}/server-conf.ldif'"
  $exec_ssl_cert_create = "echo '${ssl_cert_country}\n${ssl_cert_state}\n${ssl_cert_city}\n${ssl_cert_organization}\n${ssl_cert_department}\n${ssl_cert_domain}\n${ssl_cert_email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${ssl_key_file}' -out '${ssl_cert_file}'"
  $exec_ssl_cert_exists = "test -s '${ssl_cert_file}' || test -s '${ssl_key_file}'"

  Exec{
    path => $exec_path,
    logoutput => 'on_failure',
  }

  case $ensure {
    'present': {
      if( $ldap_conf_dir != '' ) {
        # If this is triggers, it means that the slapd config has not
        # been initialized and it is safe to blow away and recreate
        #from scratch a bit later on.
        exec{ 'ldap-notify-if-uninitialized':
          command  => 'true',
          notify   => [
            Exec[ 'ldap-server-init' ],
            Exec[ 'ldap-remove-conf' ],
          ],
          unless    => "test -d '${ldap_conf_dir}'",
        }
      }
      exec{ 'ldap-remove-conf':
        command     => $exec_remove_conf,
        require     => Package[ $packages ],
        notify      => Exec[ 'ldap-server-init' ],
        refreshonly => 'true'
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
        unless      => $exec_ssl_cert_exists,
        refreshonly => 'true'
      }

      if( ! defined( Ldap::Utils[ 'ldap::utils' ] ) ) {
        include ldap::utils::config
        ldap::utils{ 'ldap::utils':
          ensure   => 'present',
          base_dn  => inline_template( '<%= directories.at(0) %>' ),
          password => $password,
        }
      }

      package{ $packages:
        ensure  => $ensure,
        require => [
          Exec[ 'ldap-notify-if-uninitialized' ],
        ],
        notify  => Service[ $services ],
      }

      service{ $services:
        ensure  => 'running',
        enable  => 'true',
        require => [
          Ldap::Utils[ 'ldap::utils' ],
        ],
        notify  => [
          Exec[ 'ldap-server-conf' ],
        ],
      }

      directory{ [ $ldif_dir, $directory_base, $ldap_conf_dir ]:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0700',
        recurse => true,
        require => Exec[ 'ldap-remove-conf' ],
        before  => Exec[ 'ldap-server-init' ],
      }

      file{ 'ldap-server-init':
        path    => "${ldif_dir}/server-init.ldif",
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0600',
        content => template( 'ldap/server/server-init.ldif' ),
      }
      exec{ 'ldap-server-init':
        command     => $exec_server_init,
        user        => $user,
        group       => $group,
        require     => [
          File[ 'ldap-server-init'],
          Exec[ 'ldap-ssl-cert-create' ],
          Ldap::Dummy[ 'ldap::utils' ],
        ],
        notify      => [
          Service[ $services ],
          Exec[ 'ldap-server-populate' ],
        ],
        refreshonly => 'true'
      }

      file{ 'ldap-server-populate':
        path    => "${ldif_dir}/server-populate.ldif",
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => '0600',
        content => template( 'ldap/server/server-populate.ldif' ),
      }
      exec{ 'ldap-server-populate':
        command     => $exec_server_populate,
        require     => [
          File[ 'ldap-server-populate' ],
          Service[ $services ],
        ],
        notify      => [
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
        notify      => [
          Exec[ 'ldap-server-conf' ],
        ],
      }
      exec{ 'ldap-server-conf':
        command     => $exec_server_conf,
        require     => Service[ $services ],
        refreshonly => 'true',
      }

      ldap::server::directory{ $directories:
        ensure         => 'present',
        user           => $user,
        group          => $group,
        password       => $password,
        directory_base => $directory_base,
        ldif_dir       => $ldif_dir,
        require        => [ 
          Exec[ 'ldap-server-conf' ],
          Ldap::Toggle[ $conf_files ],
          Service[ $services ],
        ]
      }
    }

    'absent','purged': {
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
        require => Service[ $services ],
      }

      if( $ensure == 'purged' ) {
        directory{ [ $directory_base, $ldap_conf_dir ]:
          ensure  => 'absent',
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
    notify => Service[ $services ],
  }
}
