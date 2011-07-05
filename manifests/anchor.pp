class ldap::anchor {
  # All general server configuration must happen before this anchor.
  if( ! defined( Anchor[ 'ldap::phase1' ] ) ) {
    anchor{ 'ldap::phase1': }
  }

  # All database/directory configuration must happen after this anchor.
  if( ! defined( Anchor[ 'ldap::phase2' ] ) ) {
    anchor{ 'ldap::phase2':
      require => Anchor[ 'ldap::phase1' ]
    }
  }
}
