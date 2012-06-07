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
#
# $authentication_method::       Identifies the method of authentication used
#                                by the client. The default is "none"
#                                (anonymous).
#
# $conf_template::               The template to use for the client
#                                configuration file.
#
# $config_hash::                 A hash containing key-value pairs to be
#                                inserted into the configuration file. How
#                                they are used is dependent on the template
#                                used.
#
# $default_search_scope::        Default scope used when performing a search.
#                                Valid values are "one" or "sub".
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
#     server_list                => ['ldap1.cat.pdx.edu', 'ldap2.cat.pdx.edu'],
#     service_search_base        => 'dc=cat,dc=pdx,dc=edu',
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
  $attribute_maps              = undef,
  $authentication_method       = 'none',
  $conf_template               = undef,
  $config_hash                 = undef,
  $default_search_scope        = 'one',
  $service_search_descriptors  = undef
) {

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

}
