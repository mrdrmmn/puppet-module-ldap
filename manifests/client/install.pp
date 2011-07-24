class ldap::client::install {
  include ldap::client::config
  ldap::client{ 'ldap-client':
    ensure => 'present'
  }
}
