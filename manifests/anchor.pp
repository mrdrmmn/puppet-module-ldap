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

  if( ! defined( Anchor[ 'phase4' ] ) ) {
    anchor{ 'phase4':
      require => Anchor[ 'phase3' ]
    }
  }

  if( ! defined( Anchor[ 'phase5' ] ) ) {
    anchor{ 'phase5':
      require => Anchor[ 'phase4' ]
    }
  }

  if( ! defined( Anchor[ 'phase6' ] ) ) {
    anchor{ 'phase6':
      require => Anchor[ 'phase5' ]
    }
  }
}
