class ldap::install {
  include ldap::server::install
  include ldap::utils::install
  include ldap::client::install
}
