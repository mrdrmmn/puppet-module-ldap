class ldap::server::defaults::os inherits ldap::server::defaults {
  case $operatingsystem {
    'ubuntu': {
      $packages     = [
        'slapd',
      ]
      $services     = [
        'slapd'
      ]
      $conf_files   = [
        'present:absent:root:root:0644:server/debian/slapd:/etc/default/slapd',
      ]
      $ldap_conf_dir = '/etc/ldap/slapd.d'
    }
    'linux': {
      $packages = [
        'openldap-servers',
      ]
      $services = [
        'slapd'
      ]
      $conf_files = [
        'present:absent:root:root:0644:server/redhat/ldap:/etc/sysconfig/ldap',
      ]
      $ldap_conf_dir = '/etc/openldap/slapd.d'
      $pid_file = 'var/run/openldap/slapd.pid'
    }
    default: {
      fail( "$operatingsystem is not currently supported" )
    }
  }
}
