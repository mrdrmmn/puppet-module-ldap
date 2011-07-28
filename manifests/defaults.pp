class ldap::defaults {
  # Set up our defaults.

  # The user and group which the ldap server runs as.  
  $user                  = 'openldap'
  $group                 = 'openldap'

  # The dn that is the root of your ldap directory.  This applies to clients
  # and not to the servers.
  $base_dn               = 'dc=example,dc=com'

  # The password for the root dn.  Please don't rely on $uniqueid for this
  # in production, but it is an nice way to do things in a test environment.
  $password              = $uniqueid

  # The protocol you will use for your clients.  It is unset here because it
  # will vary depending on other configurations settings.  If you don't want
  # it to be auto determined, either pass it to the define or set it in
  # config.pp.  Vaild values are 'ldapi', 'ldap', and 'ldaps'.
  $protocol              = ''

  # The "address" of your ldap server.  This can be an ip address or the path
  # to a unix socket.  If left blank, ldap will connect locally.  Setting it
  # to a unix socket will 
  $server_addr           = ''

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

  # What ciphers should be allowed for a connection.  This will vary based on
  # you specific needs and if your version of ldap was compiled agains openssl
  # or gnutls.  For strong encryption, I think the following should be good:
  # openssl: 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'
  # gnutls:  'SECURE256:!AES-128-CBC:!ARCFOUR-128:!CAMELLIA-128-CBC:!3DES-CBC:!CAMELLIA-128-CBC'
  $ssl_cipher_suite      = 'TLSv1+HIGH:!SSLv2:!aNULL:!eNULL:!3DES:@STRENGTH'

  # The primary mode in which you want to use ssl.  Valid options are: off,
  # start_tls, and on.
  $ssl_mode              = 'yes'
  $ssl_minimum           = '256'

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

  $exec_path             = '/usr/sbin:/sbin:/usr/bin:/bin'

  # These values are arrays that should be set to a list for FQDNs that will run the
  # specified portions of this puppet module installed.  By default I set it to the
  # FQDN of the server we are running on in case you want to handle calling the
  # individual sections your self.
  $server_nodes = [ $fqdn ]
  $client_nodes = [ $fqdn ]
  $utils_nodes  = [ $fqdn ]

  # [0] - The db name based on nsswitch.
  # [1] - The method(s) used by nsswitch to look up data when ldap is disabled.
  # [2] - The method(s) used by nsswitch to look up data when ldap is enabled.
  # [3] - The OU where the data can be found in your ldap directory.
  # [4] - The key used to reference the db in ldap.conf.
  # [5] - The key used to reference the db in ldapscripts.conf.
  $db_mapping  = [
    'passwd    :compat   :compat ldap [NOTFOUND=return] db   :People   :nss_base_passwd    :USUFFIX',
    'shadow    :compat   :compat ldap [NOTFOUND=return] db   :People   :nss_base_shadow    :',
    'group     :compat   :compat ldap [NOTFOUND=return] db   :Group    :nss_base_group     :GSUFFIX',
    'hosts     :files dns:files dns ldap [NOTFOUND=return] db:Hosts    :nss_base_hosts     :',
    'services  :db files :ldap [NOTFOUND=return] db files    :Services :nss_base_services  :',
    'networks  :files    :ldap [NOTFOUND=return] files       :Networks :nss_base_networks  :',
    'netmasks  :files    :ldap [NOTFOUND=return] files       :Networks :nss_base_netmasks  :',
    'protocols :db files :ldap [NOTFOUND=return] db files    :Protocols:nss_base_protocols :',
    'rpc       :db files :ldap [NOTFOUND=return] db files    :Rpc      :nss_base_rpc       :',
    'ethers    :db files :ldap [NOTFOUND=return] db files    :Ethers   :nss_base_ethers    :',
    'bootparams:files    :ldap [NOTFOUND=return] files       :Ethers   :nss_base_bootparams:',
    'aliases   :files    :ldap [NOTFOUND=return] files       :Aliases  :nss_base_aliases   :',
    'netgroup  :nis      :ldap [NOTFOUND=return] nis         :Netgroup :nss_base_netgroup  :',
    '          :         :                                   :Machines :                   :MSUFFUX',
  ]
}
