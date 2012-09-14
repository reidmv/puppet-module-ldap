class ldap::data {

  $valid_default_search_scope  = ['one', 'sub']

  case $::osfamily {
    default:  { fail("osfamily '$::osfamily' is not supported") }
    'Debian': {
      $client_conf_template        = 'ldap/client/conf_openldap.erb'
      $client_conf_file            = [
        '/etc/ldap.conf',
        '/etc/ldap/ldap.conf',
      ]
      $client_conf_owner           = 'root'
      $client_conf_group           = 'root'
      $client_conf_mode            = '0644'
      $client_service              = [ ]
      $valid_authentication_method = [
        'none',
        'simple',
        'sasl',
        'tls',
      ]
      $client_package              = [
        'ldap-auth-client',
        'ldap-auth-config',
      ]
    }
    'Solaris': {
      $client_conf_template        = 'ldap/client/conf_solaris.erb'
      $client_conf_file            = '/var/ldap/ldap_client_file'
      $client_conf_owner           = 'root'
      $client_conf_group           = 'root'
      $client_conf_mode            = '0644'
      $client_service              = 'ldap/client'
      $valid_authentication_method = [
        'none',
        'simple',
        'tls:none',
        'tls:simple',
      ]
      $client_package              = [ ]
    }
    'RedHat': {
      $client_conf_template        = 'ldap/client/conf_openldap.erb'
      $client_conf_file            = [
        '/etc/ldap.conf',
        '/etc/openldap/ldap.conf',
      ]
      $client_conf_owner           = 'root'
      $client_conf_group           = 'root'
      $client_conf_mode            = '0644'
      $valid_authentication_method = [
        'none',
        'simple',
        'sasl',
        'tls',
      ]
      case $::operatingsystemrelease {
        default: {
          $client_service = 'nslcd'
          $client_package = [
            'openldap-clients',
            'nss-pam-ldapd',
          ]
        }
        /^5\./:  {
          $client_service = [ ]
          $client_package = 'openldap-clients'
        }
      }
    }
  }

}
