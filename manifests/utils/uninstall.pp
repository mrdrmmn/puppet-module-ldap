class ldap::utils::uninstall {
  if( ! defined( Ldap::Utils[ 'ldap::utils' ] ) ) {
    include ldap::utils::config
    ldap::utils{ 'ldap::utils':
      ensure => 'absent'
    }
  }
}
