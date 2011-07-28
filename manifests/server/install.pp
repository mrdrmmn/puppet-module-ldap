class ldap::server::install {
  if( ! defined( Ldap::Server[ 'ldap::server' ] ) ) {
    include ldap::server::config
    ldap::server{ 'ldap::server':
      ensure => 'present'
    }
  }
}
