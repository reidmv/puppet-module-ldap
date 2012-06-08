class ldap::client::debian {

  Exec {
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    require => Package[$ldap::data::client_package],
  }

  exec { 'ldap::client::debian auth-client-config':
    command => 'auth-client-config -p lac_ldap -t nss',
    unless  => 'auth-client-config -p lac_ldap -t nss -s',
  }

  exec { 'ldap::client::debian pam-auth-update':
    command => 'pam-auth-update --package ldap',
    unless  => 'pam-auth-update --package ldap',
  }

}
