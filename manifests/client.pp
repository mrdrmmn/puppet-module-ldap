# Define: ldap::client
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
  $ensure                = $ldap::client::config::ensure,
  $server_nodes          = $ldap::client::config::server_nodes,
  $client_nodes          = $ldap::client::config::client_nodes,
  $utils_nodes           = $ldap::client::config::utils_nodes,
  $user                  = $ldap::client::config::user,
  $group                 = $ldap::client::config::group,
  $base_dn               = $ldap::client::config::base_dn,
  $password              = $ldap::client::config::password,
  $protocols             = $ldap::client::config::protocols,
  $protocol              = $ldap::client::config::protocol,
  $ldap_version          = $ldap::client::config::ldap_version,
  $server_addr           = $ldap::client::config::server_addr,
  $port                  = $ldap::client::config::port,
  $ssl_port              = $ldap::client::config::ssl_port,
  $search_timelimit      = $ldap::client::config::search_timelimit,
  $bind_timelimit        = $ldap::client::config::bind_timelimit,
  $idle_timelimit        = $ldap::client::config::idle_timelimit,
  $ldif_dir              = $ldap::client::config::ldif_dir,
  $ldap_conf_dir         = $ldap::client::config::ldap_conf_dir,
  $directory_base        = $ldap::client::config::directory_base,
  $directories           = $ldap::client::config::directories,
  $args_file             = $ldap::client::config::args_file,
  $log_level             = $ldap::client::config::log_level,
  $pid_file              = $ldap::client::config::pid_file,
  $tool_threads          = $ldap::client::config::tool_threads,
  $ssl_verify_certs      = $ldap::client::config::ssl_verify_certs,
  $ssl_cacert_file       = $ldap::client::config::ssl_cacert_file,
  $ssl_cacert_path       = $ldap::client::config::ssl_cacert_path,
  $ssl_cert_file         = $ldap::client::config::ssl_cert_file,
  $ssl_key_file          = $ldap::client::config::ssl_key_file,
  $ssl_cipher_suite      = $ldap::client::config::ssl_cipher_suite,
  $ssl_rand_file         = $ldap::client::config::ssl_rand_file,
  $ssl_ephemeral_file    = $ldap::client::config::ssl_ephemeral_file,
  $ssl_minimum           = $ldap::client::config::ssl_minimum,
  $ssl_mode              = $ldap::client::config::ssl_mode,
  $sasl_minssf           = $ldap::client::config::sasl_minssf,
  $sasl_maxssf           = $ldap::client::config::sasl_maxssf,
  $ssl_cert_country      = $ldap::client::config::ssl_cert_country,
  $ssl_cert_state        = $ldap::client::config::ssl_cert_state,
  $ssl_cert_city         = $ldap::client::config::ssl_cert_city,
  $ssl_cert_organization = $ldap::client::config::ssl_cert_organization,
  $ssl_cert_department   = $ldap::client::config::ssl_cert_department,
  $ssl_cert_domain       = $ldap::client::config::ssl_cert_domain,
  $ssl_cert_email        = $ldap::client::config::ssl_cert_email,
  $bind_policy           = $ldap::client::config::bind_policy,
  $pam_min_uid           = $ldap::client::config::pam_min_uid,
  $pam_max_uid           = $ldap::client::config::pam_max_uid,
  $exec_path             = $ldap::client::config::exec_path
) {
  $packages   = $ldap::client::config::packages
  $services   = $ldap::client::config::services
  $conf_files = $ldap::client::config::conf_files
  $db_mapping = $ldap::client::config::db_mapping
  $nsswitch   = $ldap::client::config::nsswitch

  case $ensure {
    'present','installed': {
      package{ $packages:
        ensure => $ensure,
        before => Ldap::Toggle[ $conf_files ],
      }

      service{ $services:
        ensure => 'running',
        enable => 'true',
        subscribe => Ldap::Toggle[ $conf_files ],
      }
    }
    'absent','removed','purged': {
      package{ $packages:
        ensure  => $ensure,
        require => Service[ $services ],
      }
      service{ $services:
        ensure => 'stopped',
        enable => 'false',
        before => Ldap::Toggle[ $conf_files ],
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $conf_files:
    ensure  => $ensure,
  }
}
