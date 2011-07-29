define ldap::server::mk_directory_paths (
  $ensure         = $ldap::server::config::ensure,
  $user           = $ldap::server::config::user,
  $group          = $ldap::server::config::group,
  $mode           = 0700,
  $directory_base = $ldap::server::config::directory_base
) {
  directory{ "${directory_base}/${name}":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    recurse => 'true',
  }
}
