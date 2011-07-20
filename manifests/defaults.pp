class ldap::defaults {
  # Set up our defaults.

  # The user and group which the ldap server runs as.  
  $user                  = 'openldap'
  $group                 = 'openldap'

  # The dn that is the root of your ldap directory.
  $base_dn               = 'dc=example,dc=com'

  # The dn of the user that will manage your ldap directory.
  $root_dn               = "cn=root,${base_dn}"

  # The password for the root dn.  Please don't rely on $uniqueid for this
  # in production, but it is an nice way to do things in a test environment.
  $password              = $uniqueid

  # The port your ldap server listens on.
  $port                  = '389'

  # The ldap protocol version in use by your ldap server.
  $ldap_version          = '3'

  # Should the certs utilized in a connection be verified?  Allowed values
  # are:  never, allow, try, and demand.  In general, if you are using self
  # signed certs, use 'never'.  Otherwise, use 'demand'.
  $ssl_verify_certs      = 'never'

  # What ciphers should be allowed for a connection.  I would keep this,
  # but if you want/need to override it, please do so.  Be aware, that some
  # ciphers don't actually provide any encryption at all.
  $ssl_cipher_suite      = 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'

  # The primary mode in which you want to use ssl.  Valid options are: off,
  # start_tls, and on.
  $ssl_mode              = 'start_tls'

  # Users for which we should not lookup group membership via the ldap
  # directory.  This MUST be an array.
  $nss_initgroups_ignoreusers = [ 'root' ]

  # The path to your ssl certificate and key.  If these do not exist, we
  # will auto generate once for you
  $ssl_cert_file         = '/etc/ldap-ssl.crt'
  $ssl_key_file          = '/etc/ldap-ssl.key'

  # The values that will be used to generate a self signed cert if needed.
  $ssl_cert_country      = 'US'
  $ssl_cert_state        = 'California'
  $ssl_cert_city         = 'Culver City'
  $ssl_cert_organization = 'N/A'
  $ssl_cert_department   = 'N/A'
  $ssl_cert_domain       = $fqdn
  $ssl_cert_email        = "root@${fqdn}"
}
