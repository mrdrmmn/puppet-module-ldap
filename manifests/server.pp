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
define ldap::server (
  $ensure                = $ldap::server::config::ensure,
  $server_nodes          = $ldap::server::config::server_nodes,
  $client_nodes          = $ldap::server::config::client_nodes,
  $utils_nodes           = $ldap::server::config::utils_nodes,
  $admin_user            = $ldap::server::config::admin_user,
  $user                  = $ldap::server::config::user,
  $group                 = $ldap::server::config::group,
  $base_dn               = $ldap::server::config::base_dn,
  $password              = $ldap::server::config::password,
  $protocols             = $ldap::server::config::protocols,
  $protocol              = $ldap::server::config::protocol,
  $ldap_version          = $ldap::server::config::ldap_version,
  $server_addr           = $ldap::server::config::server_addr,
  $port                  = $ldap::server::config::port,
  $ssl_port              = $ldap::server::config::ssl_port,
  $search_timelimit      = $ldap::server::config::search_timelimit,
  $bind_timelimit        = $ldap::server::config::bind_timelimit,
  $idle_timelimit        = $ldap::server::config::idle_timelimit,
  $misc_dir              = $ldap::server::config::misc_dir,
  $ldap_conf_dir         = $ldap::server::config::ldap_conf_dir,
  $directory_base        = $ldap::server::config::directory_base,
  $directories           = $ldap::server::config::directories,
  $args_file             = $ldap::server::config::args_file,
  $log_level             = $ldap::server::config::log_level,
  $pid_file              = $ldap::server::config::pid_file,
  $tool_threads          = $ldap::server::config::tool_threads,
  $ssl_verify_certs      = $ldap::server::config::ssl_verify_certs,
  $ssl_cacert_file       = $ldap::server::config::ssl_cacert_file,
  $ssl_cacert_path       = $ldap::server::config::ssl_cacert_path,
  $ssl_cert_file         = $ldap::server::config::ssl_cert_file,
  $ssl_key_file          = $ldap::server::config::ssl_key_file,
  $ssl_cipher_suite      = $ldap::server::config::ssl_cipher_suite,
  $ssl_rand_file         = $ldap::server::config::ssl_rand_file,
  $ssl_ephemeral_file    = $ldap::server::config::ssl_ephemeral_file,
  $ssl_minimum           = $ldap::server::config::ssl_minimum,
  $ssl_mode              = $ldap::server::config::ssl_mode,
  $sasl_minssf           = $ldap::server::config::sasl_minssf,
  $sasl_maxssf           = $ldap::server::config::sasl_maxssf,
  $ssl_cert_country      = $ldap::server::config::ssl_cert_country,
  $ssl_cert_state        = $ldap::server::config::ssl_cert_state,
  $ssl_cert_city         = $ldap::server::config::ssl_cert_city,
  $ssl_cert_organization = $ldap::server::config::ssl_cert_organization,
  $ssl_cert_department   = $ldap::server::config::ssl_cert_department,
  $ssl_cert_domain       = $ldap::server::config::ssl_cert_domain,
  $ssl_cert_email        = $ldap::server::config::ssl_cert_email,
  $bind_policy           = $ldap::server::config::bind_policy,
  $pam_min_uid           = $ldap::server::config::pam_min_uid,
  $pam_max_uid           = $ldap::server::config::pam_max_uid,
  $exec_path             = $ldap::server::config::exec_path,
  $admin_directory       = $ldap::server::config::admin_directory
) {
  # Check to see if we have been called previously by utilizing as dummy
  # resource.
  if( defined( Ldap::Dummy[ 'ldap::server' ] ) ) {
    fail( 'The "ldap::server" define has already been called previously in your manifest!' )
  }
  ldap::dummy{ 'ldap::server': }

  $packages   = $ldap::server::config::packages
  $services   = $ldap::server::config::services
  $conf_files = $ldap::server::config::conf_files
  $schemas    = $ldap::server::config::schemas
  $db_mapping = $ldap::server::config::db_mapping

  $exec_remove_conf     = "rm -rf '${ldap_conf_dir}'"

  $server_init_file     = "${misc_dir}/server-init.ldif"
  $exec_server_init     = "slapadd -F '${ldap_conf_dir}' -d1 -n 0 -l '${server_init_file}' 2>&1"

  $server_populate_file = "${misc_dir}/server-populate.ldif"
  $exec_server_populate = "slapadd -F '${ldap_conf_dir}' -d1 -n 0 -l '${server_populate_file}' 2>&1"

  $exec_ssl_cert_create = "echo '${ssl_cert_country}\n${ssl_cert_state}\n${ssl_cert_city}\n${ssl_cert_organization}\n${ssl_cert_department}\n${ssl_cert_domain}\n${ssl_cert_email}' | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout '${ssl_key_file}' -out '${ssl_cert_file}'"
  $exec_ssl_cert_exists = "test -s '${ssl_cert_file}' || test -s '${ssl_key_file}'"

  $directory_init_file     = "${misc_dir}/directory-init.ldif"
  $exec_directory_init     = "ldapadd -Y EXTERNAL -H ldapi:/// -d1 -f '${directory_init_file}' 2>&1"
  $exec_directory_is_initialized  = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b cn=config '(&(objectClass=olcDatabaseConfig)(olcSuffix=*))' dn`\""

  $directory_populate_file = "${misc_dir}/directory-populate.ldif"
  $exec_directory_populate = "ldapadd -Y EXTERNAL -H ldapi:/// -d1 -f '${directory_populate_file}' 2>&1"
  $exec_directory_is_populated  = "test -n \"`ldapsearch -Y EXTERNAL -H ldapi:/// -LLL -Q -b '${base_dn}' '(ou=${base_dn})' dn`\""

  Exec{
    user      => 'root',
    group     => 'root',
    path      => $exec_path,
    logoutput => 'on_failure',
  }

  File{
    ensure => 'file',
    owner  => $user,
    group  => $group,
    mode   => 0600,
  }

  # Do some sanity checking on the data.
  if( ! $ldap_conf_dir or $ldap_conf_dir == '' ) {
    fail( '"ldap_conf_dir" value is not set.  you must provide a value via the config or by passing it to this define.' )
  }
  if( ! $directory_base or $directory_base == '' ) {
    fail( '"directory_base" value is not set.  you must provide a value via the config or by passing it to this define.' )
  }

  case $ensure {
    'present': {
      # If our config directory does not exist at the start of the run, it is
      # safe to continue.  Otherwise, we don't want to do anything other than
      # install packages.
      exec{ 'ldap-notify-if-uninitialized':
        command  => 'true',
        notify   => Exec[ 'ldap-remove-conf' ],
        unless    => "test -d '${ldap_conf_dir}'",
      }

      # Install our packages after we checked for an existing config and before
      # we attempt to remove the config that might be put in place by the
      # packages.
      package{ $packages:
        ensure    => $ensure,
        subscribe => Exec[ 'ldap-notify-if-uninitialized' ],
        notify    => Service[ $services ],
      }

      # This only gets executed if our config did not exist at the beginning
      # so it is safe to blow away any config that exists immediately after
      # we install our packages.
      exec{ 'ldap-remove-conf':
        command     => $exec_remove_conf,
        require     => Package[ $packages ],
        notify      => Exec[ 'ldap-server-init' ],
        refreshonly => 'true',
      }

      # Check to see if our directory base exists.  We don't want to touch
      # our ldap directory config if it does exist!
      exec{ 'ldap-notify-if-no-directory-base':
        command  => 'true',
        notify   => Exec[ 'ldap-directory-populate' ],
        before   => Directory[ $directory_base ],
        unless   => "test -d '${directory_base}'",
      }

      # Create the filesystem directories what will be used to store our
      # config and ldap directory data.
      directory{ [ $misc_dir, $directory_base, $ldap_conf_dir ]:
        ensure  => 'present',
        owner   => $user,
        group   => $group,
        mode    => 0700,
        recurse => true,
        require => Exec[ 'ldap-remove-conf' ],
        before  => Exec[ 'ldap-server-init' ],
      }

      # Make sure that we have an ssl certificate.  If not, generate a self-
      # signed certificate as long as the files are empty.
      if( ! defined( File[ $ssl_cert_file ] ) ) {
        file{ $ssl_cert_file:
          notify  => Exec[ 'ldap-ssl-cert-create' ],
        }
      }
      if( ! defined( File[ $ssl_key_file ] ) ) {
        file{ $ssl_key_file:
          notify  => Exec[ 'ldap-ssl-cert-create' ],
        }
      }
      exec{ 'ldap-ssl-cert-create':
        command     => $exec_ssl_cert_create,
        unless      => $exec_ssl_cert_exists,
        before      => Exec[ 'ldap-server-init' ],
        refreshonly => 'true',
      }

      # Create our ldif files that will be used to configure our server
      file{ 'ldap-server-init':
        path    => $server_init_file,
        content => template( 'ldap/server/server-init.ldif' ),
        before  => Exec[ 'ldap-server-init' ],
      }
      file{ 'ldap-server-populate':
        path    => $server_populate_file,
        content => template( 'ldap/server/server-populate.ldif' ),
        before  => Exec[ 'ldap-server-populate' ],
      }

      # Install and configure our ldap::utils package as it provides tools that
      # are needed to do the configuration of our ldap directories.
      if( ! defined( Ldap::Utils[ 'ldap::utils' ] ) ) {
        include ldap::utils::config
        ldap::utils{ 'ldap::utils':
          ensure   => 'present',
          base_dn  => inline_template( '<%= directories.at(0) %>' ),
          password => $password,
        }
      }

      # Now that everything is in place, we can initialize our server config.
      # This is only done if we did not have a config in place to begin with.
      exec{ 'ldap-server-init':
        user      => $user,
        group     => $group,
        command   => $exec_server_init,
        require   => Ldap::Utils[ 'ldap::utils' ],
        refreshonly => 'true',
      }
      exec{ 'ldap-server-populate':
        user      => $user,
        group     => $group,
        command     => $exec_server_populate,
        subscribe   => Exec[ 'ldap-server-init' ],
        notify      => Service[ $services ],
        refreshonly => 'true',
      }

      ldap::server::mk_directory_paths{ $directories:
        ensure         => $ensure,
        user           => $user,
        group          => $group,
        mode           => 0700,
        directory_base => $directory_base,
        before         => Exec[ 'ldap-directory-init' ],
      }
      
      # Restart our services once our config has been initialized.
      service{ $services:
        ensure    => 'running',
        enable    => 'true',
        before         => Exec[ 'ldap-directory-init' ],
      }

      # Now it is time to create our directories, but only if we created
      # our server config on this run.
      file{ 'ldap-directory-init':
        path    => $directory_init_file,
        content => template( 'ldap/server/directory-init.ldif' ),
        before  => Exec[ 'ldap-directory-init' ],
      }
      exec{ 'ldap-directory-init':
        command     => $exec_directory_init,
        subscribe   => Exec[ 'ldap-server-populate' ],
        unless      => $exec_directory_is_initialized,
        refreshonly => 'true'
      }

      # And now we can populate our directories as long as the directory base
      # did not exist when we started.
      file{ 'ldap-directory-populate':
        path    => $directory_populate_file,
        content => template( 'ldap/server/directory-populate.ldif' ),
        before  => Exec[ 'ldap-directory-populate' ],
      }
      exec{ 'ldap-directory-populate':
        command     => $exec_directory_populate,
        subscribe   => Exec[ 'ldap-directory-init' ],
        unless      => $exec_directory_is_populated,
        refreshonly => 'true',
      }
    }

    'absent','purged': {
      package{ $packages:
        ensure => $ensure,
        require => Service[ $services ],
      }

      service{ $services:
        ensure => 'stopped',
        enable => 'false',
      }

      directory{ $misc_dir:
        ensure  => 'absent',
        require => Service[ $services ],
      }

      if( $ensure == 'purged' ) {
        directory{ [ $directory_base, $ldap_conf_dir ]:
          ensure  => 'absent',
          require => Service[ $services ],
        }
      }
    }
    default: {
      fail( "'$ensure' is not a valid value for 'ensure'" )
    }
  }

  ldap::toggle{ $conf_files:
    ensure => $ensure,
    notify => Service[ $services ],
  }
}
