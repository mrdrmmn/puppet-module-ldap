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
  $exec_path             = $ldap::server::config::exec_path
) {
  $db_mapping = $ldap::server::config::db_mapping

  $directory_path                = "${directory_base}/${base_dn}"
  $directory_init_file           = "${ldif_dir}/${base_dn}-init.ldif"
  $exec_directory_initialize     = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${directory_init_file}'"
  $exec_directory_is_initialized = "test -n \"`slapcat -b cn=config -a '(&(objectClass=olcDatabaseConfig)(olcSuffix=${base_dn}))'`\""
  $directory_populate_file       = "${ldif_dir}/${base_dn}-populate.ldif"
  $exec_directory_populate       = "ldapadd -Y EXTERNAL -H ldapi:/// -f '${directory_populate_file}'"
  $exec_directory_is_populated   = "ldapsearch -Z -y /etc/ldap.secret -D '${base_dn}' -LLL -s base"
  $directory_conf_file           = "${ldif_dir}/${base_dn}-conf.ldif"
  $exec_directory_configure      = "ldapmodify -Y EXTERNAL -H ldapi:/// -f '${directory_conf_file}'"
  $exec_directory_is_configured  = "test -n \"`ldapsearch -Z -y /etc/ldap.secret -D '${base_dn}' -LLL -s base 2>/dev/null`\""

  Exec{ 
    path => $exec_path,
    logoutput => 'on_failure'
  }

  case $ensure {
    'present','installed': {
      ::directory{ $directory_path:
        owner   => $user,
        group   => $group,
        mode    => 0700,
        recurse => 'true',
      }

      file{ $directory_init_file:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        content => template( 'ldap/server/directory-init.ldif' ),
      }
      exec{ $exec_directory_initialize:
        unless  => $exec_directory_is_initialized,
        require => [
          ::Directory[ $directory_path ],
          File[ $directory_init_file ],
        ],
      }

      file{ $directory_populate_file:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        content => template( 'ldap/server/directory-populate.ldif' ),
      }
      exec{ $exec_directory_populate:
        unless  => $exec_directory_is_populated,
        require => [
          ::Directory[ $directory_path ],
          File[ $directory_populate_file ],
          Exec[ $exec_directory_initialize ],
        ],
      }

      file{ $directory_conf_file:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        content => template( 'ldap/server/directory-conf.ldif' ),
        notify  => Exec[ $exec_directory_configure ],
      }
      exec{ $exec_directory_configure:
        require     => [ 
          Exec[ $exec_directory_populate ],
          File[ $directory_conf_file ],
        ],
        refreshonly => 'true'
      }
    }
    
    'absent','removed': {
    }
    default: {
      fail( 'ensure must be one of the following: present, installed, absent, removed' )
    }
  }
}
