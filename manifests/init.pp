# == Class: autofs
#
# Full description of class autofs here.
#
# === Parameters
#
# [*mounts*]
#   A hash of mount resources:
#   Example:
#    {
#     'net' => { remote     => 'nfs:/server',
#                mountpoint => '/remote/server',
#                options    => 'soft,ro',
#              },
#     'home' => { remote     => 'nfs:/export/home',
#                mountpoint => '/home',
#                options    => 'hard,rw',
#              },
#    }
#
# [*package_name*]
#   Explanation of what this parameter affects and what it defaults to.
#
# [*service_name*]
#   Name of service
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
class autofs (
  $mounts            = $::autofs::params::mounts,
  $package_name      = $::autofs::params::package_name,
  $service_name      = $::autofs::params::service_name,
  $config_file       = $::autofs::params::config_file,
  $config_file_user  = $::autofs::params::config_file_user,
  $config_file_group = $::autofs::params::config_file_group,
  $config_file_mode  = $::autofs::params::config_file_mode,) inherits ::autofs::params {

  validate_hash($mounts)
  validate_string($package_name)
  validate_string($service_name)
  validate_string($config_file)
  validate_string($config_file_user)
  validate_string($config_file_group)
  validate_string($config_file_mode)

  class { '::autofs::install': } ->
  class { '::autofs::config': } ~>
  class { '::autofs::service': } ->
  Class['::autofs']
}
