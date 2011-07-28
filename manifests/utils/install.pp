class ldap::utils::install {
  if( ! defined( Ldap::Utils[ 'ldap::utils' ] ) ) {
    include ldap::utils::config
    ldap::utils{ 'ldap::utils':
      ensure => 'present'
    }
  }
}
