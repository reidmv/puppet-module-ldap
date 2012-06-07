class ldap::data {

  $valid_default_search_scope  = ['one', 'sub']
  $valid_authentication_method = ['none', 'simple', 'sasl', 'tls']

  case $::osfamily {
    default:  { fail("osfamily '$::osfamily' is not supported") }
    'Debian': {
      $client_conf_template = 'ldap/client/conf_debian.erb'
      $client_conf_file     = '/etc/ldap.conf'
      $client_conf_owner    = 'root'
      $client_conf_group    = 'root'
      $client_conf_mode     = '0644'
      $client_service       = [ ]
      $client_package       = [
        'libnss-ldap',
        'libpam-ldap',
        'libldap-2.4-2',
      ]
    }
    'Solaris': {
      $client_conf_template = 'ldap/client/conf_solaris.erb'
      $client_conf_file     = '/var/ldap/ldap_client_file'
      $client_conf_owner    = 'root'
      $client_conf_group    = 'root'
      $client_conf_mode     = '0644'
      $client_service       = 'ldap/client'
      $client_package       = [ ]
    }
  }

}
