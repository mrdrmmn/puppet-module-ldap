class ldap::server::defaults inherits ldap::config {
  $ldif_dir           = '/var/lib/puppet/state/modules/ldap'
  $directory_base     = '/var/lib/ldap'
  $directories        = $base_dn
  $args_file          = ''
  $log_level          = 'none'
  $pid_file           = ''
  $tool_threads       = ''
  $ssl_rand_file      = ''
  $ssl_ephemeral_file = ''
}
