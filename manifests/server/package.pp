define ldap::server::package(
  $ensure
) {
  package{ $name:
    ensure => $ensure
  }
}
