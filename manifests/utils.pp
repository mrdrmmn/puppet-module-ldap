# Define: ldap::utils
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
define ldap::utils (
  $ensure                = $ldap::utils::config::ensure,
  $server_nodes          = $ldap::utils::config::server_nodes,
  $client_nodes          = $ldap::utils::config::client_nodes,
  $utils_nodes           = $ldap::utils::config::utils_nodes,
  $admin_user            = $ldap::utils::config::admin_user,
  $user                  = $ldap::utils::config::user,
  $group                 = $ldap::utils::config::group,
  $base_dn               = $ldap::utils::config::base_dn,
  $password              = $ldap::utils::config::password,
  $protocols             = $ldap::utils::config::protocols,
  $protocol              = $ldap::utils::config::protocol,
  $ldap_version          = $ldap::utils::config::ldap_version,
  $server_addr           = $ldap::utils::config::server_addr,
  $port                  = $ldap::utils::config::port,
  $ssl_port              = $ldap::utils::config::ssl_port,
  $search_timelimit      = $ldap::utils::config::search_timelimit,
  $bind_timelimit        = $ldap::utils::config::bind_timelimit,
  $idle_timelimit        = $ldap::utils::config::idle_timelimit,
  $misc_dir              = $ldap::utils::config::misc_dir,
  $ldap_conf_dir         = $ldap::utils::config::ldap_conf_dir,
  $directory_base        = $ldap::utils::config::directory_base,
  $directories           = $ldap::utils::config::directories,
  $args_file             = $ldap::utils::config::args_file,
  $log_level             = $ldap::utils::config::log_level,
  $pid_file              = $ldap::utils::config::pid_file,
  $tool_threads          = $ldap::utils::config::tool_threads,
  $ssl_verify_certs      = $ldap::utils::config::ssl_verify_certs,
  $ssl_cacert_file       = $ldap::utils::config::ssl_cacert_file,
  $ssl_cacert_path       = $ldap::utils::config::ssl_cacert_path,
  $ssl_cert_file         = $ldap::utils::config::ssl_cert_file,
  $ssl_key_file          = $ldap::utils::config::ssl_key_file,
  $ssl_cipher_suite      = $ldap::utils::config::ssl_cipher_suite,
  $ssl_rand_file         = $ldap::utils::config::ssl_rand_file,
  $ssl_ephemeral_file    = $ldap::utils::config::ssl_ephemeral_file,
  $ssl_minimum           = $ldap::utils::config::ssl_minimum,
  $ssl_mode              = $ldap::utils::config::ssl_mode,
  $sasl_minssf           = $ldap::utils::config::sasl_minssf,
  $sasl_maxssf           = $ldap::utils::config::sasl_maxssf,
  $ssl_cert_country      = $ldap::utils::config::ssl_cert_country,
  $ssl_cert_state        = $ldap::utils::config::ssl_cert_state,
  $ssl_cert_city         = $ldap::utils::config::ssl_cert_city,
  $ssl_cert_organization = $ldap::utils::config::ssl_cert_organization,
  $ssl_cert_department   = $ldap::utils::config::ssl_cert_department,
  $ssl_cert_domain       = $ldap::utils::config::ssl_cert_domain,
  $ssl_cert_email        = $ldap::utils::config::ssl_cert_email,
  $bind_policy           = $ldap::utils::config::bind_policy,
  $pam_min_uid           = $ldap::utils::config::pam_min_uid,
  $pam_max_uid           = $ldap::utils::config::pam_max_uid,
  $exec_path             = $ldap::utils::config::exec_path
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Ldap::Dummy[ 'ldap::utils' ] ) ) {
    fail( 'The "ldap::utils" define has already been called previously in your manifest!' )
  }
  ldap::dummy{ 'ldap::utils': }

  $packages   = $ldap::utils::config::packages
  $conf_files = $ldap::utils::config::conf_files
  $db_mapping = $ldap::utils::config::db_mapping

  case $ensure {
    'present': {
      package{ $packages:
        ensure => 'present',
      }
    }

    'absent','purged': {
      package{ $packages:
        ensure => $ensure,
      }
    }

    default: {
      fail( "'$ensure' is not a recognized valued for 'ensure'" )
    }
  }

  toggle{ $conf_files:
    ensure     => $ensure,
    require    => Package[ $packages ],
  }
}
