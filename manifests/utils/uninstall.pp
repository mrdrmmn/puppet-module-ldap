class ldap::utils::uninstall {
  include ldap::utils::config
  ldap::utils{ 'ldap-utils':
    ensure => 'absent'
  }
}
