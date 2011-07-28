class ldap::server::uninstall {
  if( ! defined( Ldap::Server[ 'ldap::server' ] ) ) {
    include ldap::server::config
    ldap::server{ 'ldap::server':
      ensure => 'purged'
    }
  }
}
