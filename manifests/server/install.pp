class ldap::server::install {
  include ldap::server::config
  ldap::server{ 'ldap-server':
    ensure => 'present'
  }
}
