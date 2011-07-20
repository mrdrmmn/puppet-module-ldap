define ldap::toggle (
  $ensure
) {
  $present = inline_template( '<%= name.split(":").at(0) %>' )
  $absent  = inline_template( '<%= name.split(":").at(1) %>' )
  $owner   = inline_template( '<%= name.split(":").at(2) %>' )
  $group   = inline_template( '<%= name.split(":").at(3) %>' )
  $mode    = inline_template( '<%= name.split(":").at(4) %>' )
  $tmpl    = inline_template( '<%= name.split(":").at(5) %>' )
  $file    = inline_template( '<%= name.split(":").at(6) %>' )

  file{ $file:
    ensure  => $ensure ? {
      'present'   => $present,
      'installed' => $present,
      default     => $absent
    },
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template( "ldap/${tmpl}" )
  }
}
