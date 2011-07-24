class ldap::server::uninstall {
  include ldap::server::config
  ldap::server{ 'ldap-server':
    ensure => 'purged'
  }
}
