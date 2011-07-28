class ldap::server::defaults inherits ldap::config {
  $ldif_dir           = '/var/ldap/ldif'
  $directory_base     = '/var/ldap/directories'
  $directories        = [ $base_dn ]
  $log_level          = 'none'
  $args_file          = '/var/run/slapd/slapd.args'
  $pid_file           = '/var/run/slapd/slapd.pid'
  $tool_threads       = ''
  $ssl_rand_file      = ''
  $ssl_ephemeral_file = ''
  $protocols          = [ 'ldapi', 'ldaps' ]
  $schemas            = [
    'core.ldif',
    'cosine.ldif',
    'inetorgperson.ldif',
    'misc.ldif',
    'nis.ldif',
    'openldap.ldif',
  ]
}
