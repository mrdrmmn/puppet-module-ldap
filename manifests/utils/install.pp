class ldap::utils::install {
  include ldap::utils::config
  ldap::utils{ 'ldap-utils':
    ensure => 'present'
  }
}
