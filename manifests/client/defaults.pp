class ldap::client::defaults inherits ldap::config {
  $bind_policy                = 'soft'
  $nss_initgroups_ignoreusers = [ 'root' ]
  $pam_min_uid                = 1000
  $pam_max_uid                = 1000
}
