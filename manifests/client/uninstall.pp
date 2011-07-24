class ldap::client::uninstall {
  include ldap::client::config
  ldap::client{ 'ldap-client':
    ensure => 'purged'
  }
}
