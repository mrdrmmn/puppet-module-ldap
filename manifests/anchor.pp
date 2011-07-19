class ldap::anchor {
  if( ! defined( Anchor[ 'phase1' ] ) ) {
    anchor{ 'phase1': }
  }

  if( ! defined( Anchor[ 'phase2' ] ) ) {
    anchor{ 'phase2':
      require => Anchor[ 'phase1' ]
    }
  }

  if( ! defined( Anchor[ 'phase3' ] ) ) {
    anchor{ 'phase3':
      require => Anchor[ 'phase2' ]
    }
  }
}
