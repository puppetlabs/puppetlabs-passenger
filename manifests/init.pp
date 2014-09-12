# Class: passenger
#
# This class installs Passenger (mod_rails) on your system.
# http://www.modrails.com
#
# Parameters:
#   [*passenger_version*]
#     The Version of Passenger to be installed
#
#   [*passenger_ruby*]
#     The path to ruby on your system
#
#   [*gem_path*]
#     The path to rubygems on your system
#
#   [*gem_binary_path*]
#     Path to Rubygems binaries on your system
#
#   [*passenger_root*]
#     The passenger gem root directory
#
#   [*mod_passenger_location*]
#     Path to Passenger's mod_passenger.so file
#
#   [*passenger_provider*]
#     The package provider to use for the system
#
#   [*passenger_package*]
#     The name of the Passenger package
#
# Usage:
#
#  class { 'passenger':
#    passenger_version      => '3.0.21',
#    passenger_ruby         => '/usr/bin/ruby'
#    gem_path               => '/var/lib/gems/1.8/gems',
#    gem_binary_path        => '/var/lib/gems/1.8/bin',
#    passenger_root         => '/var/lib/gems/1.8/gems/passenger-3.0.21'
#    mod_passenger_location => '/var/lib/gems/1.8/gems/passenger-3.0.21/ext/apache2/mod_passenger.so',
#    passenger_provider     => 'gem',
#    passenger_package      => 'passenger',
#  }
#
#
# Requires:
#   - apache
#   - apache::dev
#
class passenger (
  $gem_binary_path        = $passenger::params::gem_binary_path,
  $gem_path               = $passenger::params::gem_path,
  $package_name           = $passenger::params::package_name,
  $package_ensure         = $passenger::params::package_ensure,
  $package_provider       = $passenger::params::package_provider,
  $passenger_package      = $passenger::params::passenger_package,
  $passenger_provider     = $passenger::params::passenger_provider,
  $passenger_ruby         = $passenger::params::passenger_ruby,
  $passenger_version      = $passenger::params::passenger_version,
) inherits passenger::params {

  # logic to work around params.pp issues
  case $::architecture {
    'i386': {
      $libpath = 'lib'
    }
    'x86_64': {
      $libpath = 'lib64'
    }
    default: {
      fail("Architecture $::architecture is unsupported by the passenger module.")
    }
  }
  case $::osfamily {
    'debian': {
      $passenger_root         = "/var/lib/gems/1.8/gems/passenger-${passenger_version}"
      $mod_passenger_location = "/var/lib/gems/1.8/gems/passenger-${passenger_version}/ext/apache2/mod_passenger.so"
    }
    'redhat': {
      $passenger_root         = "/usr/${libpath}/ruby/gems/1.8/gems/passenger-${passenger_version}"
      $mod_passenger_location = "/usr/${libpath}/ruby/gems/1.8/gems/passenger-${passenger_version}/buildout/apache2/mod_passenger.so"
    }
  }

  include '::apache'
  include '::apache::dev'

  include '::passenger::install'
  include '::passenger::config'
  include '::passenger::compile'

  anchor { 'passenger::begin': }
  anchor { 'passenger::end': }

  #projects.puppetlabs.com - bug - #8040: Anchoring pattern
  Anchor['passenger::begin'] ->
  Class['apache::dev'] ->
  Class['passenger::install'] ->
  Class['passenger::compile'] ->
  Class['passenger::config'] ->
  Anchor['passenger::end']

}
