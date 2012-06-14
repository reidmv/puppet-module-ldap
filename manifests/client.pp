# = Class: ldap::client
#
# This class installs ldap client software and configures a unix/linux
# machine to use an ldap server for various name services. The interface and
# language is based on RFC4876.
#
# == Parameters:
#
# $default_search_base::         Default base for searches.
#
# $server_list::                 An array of servers, specified either as
#                                fully-qualified DNS names or ip addresses,
#                                which the client will query (in order) for
#                                name service information.
#
# $attribute_maps::              Attribute mappings used by the client.
#                                Specified as a hash in the form
#                                { $service => $map }. e.g.
#                                { 'automount' => 'automountMapName=ou' } or
#                                { 'homeDirectory' => 'mailDirectory' }.
#                                Exactly how these entries are used is
#                                dependent on the template used.
#
# $authentication_method::       Identifies the method of authentication used
#                                by the client. The default is "none"
#                                (anonymous).
#
# $conf_template::               The template to use for the client
#                                configuration file.
#
# $default_search_scope::        Default scope used when performing a search.
#                                Valid values are "one" or "sub".
#
# $options::                     An array containing values to to be
#                                inserted into the configuration file. How
#                                they are used is dependent on the template
#                                used.
#
# $service_authentication_methods::  An array containing authentication
#                                    methods to use on a per-service basis.
#                                    Each entry should be of the form
#                                    $service:$method, e.g. (on solaris)
#                                    "pam_ldap:tls:simple"
#
# $service_search_descriptors::  An array containing search descriptors
#                                required, used, or supported by the in-line
#                                specified service or agent. Each entry
#                                should be of the form $service:$descriptor,
#                                e.g. "passwd:ou=People,dc=cat,dc=pdx,dc=edu"
#
# == Actions:
#   Setup and install an LDAP client
#
# == Sample Usage:
#
#   class { 'ldap::client':
#     server_list                => 'ldaps://ldap.cat.pdx.edu',
#     default_search_base        => 'dc=cat,dc=pdx,dc=edu',
#     attribute_maps             => {
#       'homeDirectory' => 'mailDirectory',
#     },
#     service_search_descriptors => [
#       'passwd:ou=people,dc=cat,dc=pdx,dc=edu',
#       'shadow:ou=people,dc=cat,dc=pdx,dc=edu?one?pod=cat',
#       'group:ou=group,dc=cat,dc=pdx,dc=edu',
#     ],
#   }
#
class ldap::client (
  $default_search_base,
  $server_list,
  $dua_config_profile             = undef,
  $attribute_maps                 = undef,
  $authentication_method          = 'none',
  $conf_template                  = undef,
  $default_search_scope           = 'one',
  $options                        = undef,
  $service_authentication_methods = undef,
  $service_search_descriptors     = undef
) {
  include ldap::data

  if !($default_search_scope in $ldap::data::valid_default_search_scope) {
    fail("default_search_scope $default_search_scope invalid")
  }

  if !($authentication_method in $ldap::data::valid_authentication_method) {
    fail("authentication_method $authentication_method invalid")
  }

  if !$conf_template {
    $conf_template_real = $ldap::data::client_conf_template
  } else {
    $conf_template_real = $conf_template
  }

  package { $ldap::data::client_package:
    ensure => present,
  }

  file { $ldap::data::client_conf_file:
    ensure  => present,
    owner   => $ldap::data::client_conf_owner,
    group   => $ldap::data::client_conf_group,
    mode    => $ldap::data::client_conf_mode,
    content => template($conf_template_real),
    require => Package[$ldap::data::client_package],
  }

  service { $ldap::data::client_service:
    ensure    => running,
    enable    => true,
    subscribe => File[$ldap::data::client_conf_file],
  }

  # the details of ldap client configuration from this point forward can't be
  # generalized. Actually some would argue that even the stuff we've tried to
  # generalize can't be generalized. Split out more configuration by osfamily
  case $::osfamily {
    default:  { } # no extra configuration needed
    'Debian': {
      class { 'ldap::client::debian': }
    }
    'Solaris': {
      class { 'ldap::client::solaris': }
    }
  }

}
