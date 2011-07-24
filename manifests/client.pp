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
  $ensure           = $ldap::client::config::ensure,
  $base_dn          = $ldap::client::config::base_dn,
  $root_dn          = $ldap::client::config::root_dn,
  $password         = $ldap::client::config::password,
  $protocol         = $ldap::client::config::protocol,
  $search_timelimit = $ldap::client::config::search_timelimit,
  $bind_timelimit   = $ldap::client::config::bind_timeout,
  $bind_policy      = $ldap::client::config::bind_policy,
  $ldap_version     = $ldap::client::config::ldap_version,
  $port             = $ldap::client::config::port,
  $pam_min_uid      = $ldap::client::config::pam_min_uid,
  $pam_max_uid      = $ldap::client::config::pam_max_uid,
  $ssl_mode         = $ldap::client::config::ssl_mode
) {
  $packages         = $ldap::client::config::packages
  $conf_files       = $ldap::client::config::conf_files
  # Ensure our anchor points exist.
  include ldap::anchor

  case $ensure {
    'present','installed': {
      package{ $packages:
        ensure => $ensure,
      }
    }
    'absent','removed','purged': {
      package{ $packages:
        ensure => $ensure,
      }
    }
    default: {
      fail( "'$config_ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $conf_files:
    ensure => $ensure,
  }
}
