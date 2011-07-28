class ldap::uninstall {
  ldap{ 'uninstall':
    ensure       => 'absent',
  }
}
