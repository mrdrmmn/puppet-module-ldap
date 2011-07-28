class ldap::install {
  ldap{ 'install':
    ensure       => 'present',
  }
}
