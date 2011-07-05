define ldap::server::service(
  $ensure,
  $enable
) {
  if( ! defined( Service[ $name ] ) ) {
    service{ $name:
      ensure => $ensure,
      enable => $enable
    }
  }
}
