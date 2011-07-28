class ldap::client::uninstall {
  if( ! defined( Ldap::Client[ 'ldap::client' ] ) ) {
    include ldap::client::config
    ldap::client{ 'ldap::client':
      ensure => 'absent'
    }
  }
}
