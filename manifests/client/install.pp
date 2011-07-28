class ldap::client::install {
  if( ! defined( Ldap::Client[ 'ldap::client' ] ) ) {
    include ldap::client::config
    ldap::client{ 'ldap::client':
      ensure => 'present'
    }
  }
}
