class ldap::client::redhat (
  $server_list,
  $default_search_base,
) {

  Exec {
    path     => '/usr/sbin:/usr/bin:/sbin:/bin',
    provider => shell,
    require  => Package[$ldap::data::client_package],
    before   => File[$ldap::data::client_conf_file],
  }

  $ldapservers = join([$server_list], ',')
  $basedn = $default_search_base

  exec { 'ldap::client::redhat authconfig ldapserver':
    command => "authconfig --ldapserver=${ldapservers} --update",
    unless  => "authconfig --test | grep 'LDAP server = \"${ldapservers}\"'",
  }

  exec { 'ldap::client::redhat authconfig ldapbasedn':
    command => "authconfig --ldapbasedn=${basedn} --update",
    unless  => "authconfig --test | grep 'LDAP base DN = \"${basedn}\"'",
  }

  exec { 'ldap::client::redhat authconfig nss_ldap':
    command => 'authconfig --enableldap --update',
    unless  => 'authconfig --test | grep "nss_ldap is enabled"',
  }

  exec { 'ldap::client::redhat authconfig pam_ldap':
    command => 'authconfig --enableldapauth --update',
    unless  => 'authconfig --test | grep "pam_ldap is enabled"',
  }

}
