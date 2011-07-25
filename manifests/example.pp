class ldap::example {
  # These are the nodes that will run our ldap server.  If there is more than
  # one, they will be configured to replicate each other.  They will each be
  # assigned a uniqued id that is their position in this list.  Changing this
  # order later will likely cause replication problems that you will have to
  # work our on your own.
  $server_nodes = [
    'ldap01.example.com',
    'ldap02.example.com',
    'ldap03.example.net',
  ]

  # These are the nodes that will be clients of our ldap servers.  Note that
  # our servers can also be clients.
  $client_nodes = [
    $server_nodes,
    'client01.example.com',
    'client02.example.com',
    'client03.example.net',
  ]

  # These are the nodes that will have the ldap utils installed on them.  All
  # server nodes will already have this installed, but that is not a problem.
  $utils_nodes = $client_nodes

  # Load in our configuration.  This is required.
  include ldap::config
  
  # Call our primary define.  The title passed in is not important.  No
  # matter what you call it, you will only be able to trigger this define
  # one time.  Attempting to call in multiple times will result in your
  # manifest failing!
  ldap{ 'install':
    ensure            => 'present',
    server_nodes => $server_nodes,
    client_nodes => $client_nodes,
    utils_nodes  => $utils_nodes,
  }
}
