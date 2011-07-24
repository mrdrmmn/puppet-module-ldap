class ldap::uninstall {
  include ldap::server::uninstall
  include ldap::utils::uninstall
  include ldap::client::uninstall
}
