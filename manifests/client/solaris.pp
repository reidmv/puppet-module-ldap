class ldap::client::solaris inherits ldap::client {

  $stamp_file_auto   = '/var/ldap/.puppet_ldap_client_auto'
  $stamp_file_manual = '/var/ldap/.puppet_ldap_client_manual'

  # Solaris can do DUAConfigClient stuff. If that option was passed, don't
  # manage the file directly. Instead, run the ldapclient command with the
  # appropriate options.
  if $ldap::client::dua_config_client {

    File[$ldap::data::client_conf_file] {
      content => undef,
    }

    $stamp_file        = $stamp_file_auto
    $dua_config_client = $ldap::client::dua_config_client
    $server_array      = [$ldap::client::server_list]
    $first_server      = $server_array[0]
    $command           = [
      "ldapclient init -a profileName=$dua_config_client $first_server",
      ' && ',
      "touch $stamp_file_auto",
      ' ; ',
      "rm -f $stamp_file_manual",
    ]

  } else {

    $stamp_file = $stamp_file_manual
    $command    = [
      '/bin/true', # TODO
      ' && ',
      "touch $stamp_file_manual",
      ' ; ',
      "rm -f $stamp_file_auto",
    ]

  }

  exec { 'ldap::client ldapclient':
    provider => shell,
    path     => '/sbin:/usr/sbin:/bin:/usr/bin',
    command  => " $command ",
    creates  => $stamp_file,
  }

}
