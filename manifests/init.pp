# Class: ldap
#
# This module manages ldap
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class ldap {
  ldap::server{ 'ldap_server':
    ensure => 'installed',
    directories => 'dc=example,dc=com'
  }
}
