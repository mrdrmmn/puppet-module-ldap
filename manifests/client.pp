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
  $ensure           = '',
  $basedn           = '',
  $rootdn           = '',
  $password         = '',
  $ldap_uri         = '',
  $search_timelimit = '',
  $bind_timelimit   = '',
  $bind_policy      = '',
  $packages         = '',
  $ldap_version     = '',
  $port             = '',
  $pam_min_uid      = '',
  $pam_max_uid      = '',
  $ssl_mode         = '',
  $conf_files       = ''
) {
  # Ensure our anchor points exist.
  include ldap::anchor

  # Load our defaults and generate our config values.
  include ldap::client::defaults
  $config_ensure               = $ensure ? {
    ''      => $ldap::client::defaults::ensure,
    default => $ensure
  }
  $config_basedn               = $basedn ? {
    ''      => $ldap::client::defaults::basedn,
    default => $basedn
  }
  $config_rootdn               = $rootdn ? {
    ''      => $ldap::client::defaults::rootdn,
    default => $rootdn
  }
  $config_password             = $password ? {
    ''      => $ldap::client::defaults::password,
    default => $password
  }
  $config_ldap_uri             = $ldap_uri ? {
    ''      => $ldap::client::defaults::ldap_uri,
    default => $ldap_uri
  }
  $config_search_timelimit     = $search_timelimit ? {
    ''      => $ldap::client::defaults::search_timelimit,
    default => $search_timelimit
  }
  $config_bind_timelimit             = $bind_timelimit ? {
    ''      => $ldap::client::defaults::bind_timelimit,
    default => $bind_timelimit
  }
  $config_bind_policy                = $bind_policy ? {
    ''      => $ldap::client::defaults::bind_policy,
    default => $bind_policy
  }
  $config_packages                   = $packages ? {
    ''      => $ldap::client::defaults::packages,
    default => $packages
  }
  $config_ldap_version               = $ldap_version ? {
    ''      => $ldap::client::defaults::ldap_version,
    default => $ldap_version
  }
  $config_port                       = $port ? {
    ''      => $ldap::client::defaults::port,
    default => $port
  }
  $config_pam_min_uid                = $pam_min_uid ? {
    ''      => $ldap::client::defaults::pam_min_uid,
    default => $pam_min_uid
  }
  $config_pam_max_uid                = $pam_max_uid ? {
    ''      => $ldap::client::defaults::pam_max_uid,
    default => $pam_max_uid
  }
  $config_ssl_mode                   = $ssl_mode ? {
    ''      => $ldap::client::defaults::ssl_mode,
    default => $ssl_mode
  }
  $config_tls_checkpeer              = $tls_checkpeer ? {
    ''      => $ldap::client::defaults::tls_checkpeer,
    default => $tls_checkpeer
  }
  $config_tls_ciphers                = $tls_ciphers ? {
    ''      => $ldap::client::defaults::tls_ciphers,
    default => $tls_ciphers
  }
  $config_nss_initgroups_ignoreusers = $nss_initgroups_ignoreusers ? {
    ''      => $ldap::client::defaults::nss_initgroups_ignoreusers,
    default => $nss_initgroups_ignoreusers
  }
  $config_conf_files                 = $conf_files ? {
    ''      => $ldap::client::defaults::conf_files,
    default => $conf_files
  }

  case $config_ensure {
    'present','installed': {
      package{ $config_packages:
        ensure => $config_ensure,
      }
    }
    'absent','removed','purged': {
      package{ $config_packages:
        ensure => $config_ensure,
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $config_conf_files:
    config_ensure           => $config_ensure,
    config_basedn           => $config_basedn,
    config_rootdn           => $config_rootdn,
    config_password         => $config_password,
    config_ldap_uri         => $config_ldap_uri,
    config_search_timelimit => $config_search_timelimit,
    config_bind_timelimit   => $config_bind_timelimit,
    config_bind_policy      => $config_bind_policy,
    config_packages         => $config_packages,
    config_ldap_version     => $config_ldap_version,
    config_port             => $config_port,
    config_pam_min_uid      => $config_pam_min_uid,
    config_pam_max_uid      => $config_pam_max_uid,
    config_ssl_mode         => $config_ssl_mode,
    config_conf_files       => $config_conf_files,
    config_mode             => 'client',
  }
}
