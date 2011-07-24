class ldap::defaults {
  # Set up our defaults.

  # The user and group which the ldap server runs as.  
  $user                  = 'openldap'
  $group                 = 'openldap'

  # The dn that is the root of your ldap directory.
  $base_dn               = 'dc=example,dc=com'

  # The cn of the root dn.  The root dn will be 'cn=$root_cn,$base_dn' for the
  # purposes of the client and utils manifests.  For the server end of things,
  # the root dn will be 'cn=$root_cn' prepended onto each entry in
  # $directories.
  $root_cn               = root
  # The dn of the user that will manage your ldap directory.
  $root_dn               = "cn=${root_cn},${base_dn}"

  # The password for the root dn.  Please don't rely on $uniqueid for this
  # in production, but it is an nice way to do things in a test environment.
  $password              = $uniqueid

  # The port on which your ldap server listens on.
  $port                  = '389'

  # The port on which your ldap server expects "always on" ssl connections.
  $ssl_port              = '636'

  # The ldap protocol version in use by your ldap server.
  $ldap_version          = '3'

  # Should the certs utilized in a connection be verified?  Allowed values
  # are:  never, allow, try, and demand.  In general, if you are using self
  # signed certs, use 'never'.  Otherwise, use 'demand'.
  $ssl_verify_certs      = 'never'

  # What ciphers should be allowed for a connection.  I would keep this,
  # but if you want/need to override it, please do so.  Be aware, that some
  # ciphers don't actually provide any encryption at all.
  #$ssl_cipher_suite      = 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'
  $ssl_cipher_suite      = 'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'

  # The primary mode in which you want to use ssl.  Valid options are: off,
  # start_tls, and on.
  $ssl_mode              = 'start_tls'
  $ssl_minimum           = '128'

  # Users for which we should not lookup group membership via the ldap
  # directory.  This MUST be an array.
  $nss_initgroups_ignoreusers = [ 'root' ]

  # The path to your ssl certificate and key.  If these do not exist, we
  # will auto generate once for you
  $ssl_cert_file         = '/etc/ldap/ssl.crt'
  $ssl_key_file          = '/etc/ldap/ssl.key'
  $ssl_cacert_file       = ''
  $ssl_cacert_path       = ''

  $ssl_rand_file         = ''

  # sasl security properties.  this is only used locally and as near as I
  # can figure out, sasl does not work properly will ssl, so keep it a 0.
  # This should not be a problem as this only works over the unix socket
  # so it should be safe.
  $sasl_minssf           = '0'
  $sasl_maxssf           = ''

  $search_timelimit      = 15
  $bind_timelimit        = 15
  $idle_timelimit        = 15

  # The values that will be used to generate a self signed cert if needed.
  $ssl_cert_country      = 'US'
  $ssl_cert_state        = 'California'
  $ssl_cert_city         = 'Culver City'
  $ssl_cert_organization = 'N/A'
  $ssl_cert_department   = 'N/A'
  $ssl_cert_domain       = $fqdn
  $ssl_cert_email        = "root@${fqdn}"
  
  $protocol              = 'ldapi'
}
