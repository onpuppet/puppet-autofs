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
# [*mount_files*]
#   A hash of files to populate and include in auto.master
#   Example:
#     {
#       'home' => {
#         mountpoint  => '/home',
#         file_source => 'puppet:///modules/mymodule/auto.home',
#         file_mode   => '0644',
#       }
#     }
#
# [*mount_entries*]
#   A hash of entries to be added to auto.master
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
  $mount_files       = $::autofs::params::mount_files,
  $mount_entries     = $::autofs::params::mount_entries,
  $package_name      = $::autofs::params::package_name,
  $service_name      = $::autofs::params::service_name,
  $config_file       = $::autofs::params::config_file,
  $config_file_owner = $::autofs::params::config_file_owner,
  $config_file_group = $::autofs::params::config_file_group,
  $config_file_mode  = $::autofs::params::config_file_mode,) inherits ::autofs::params {

  validate_hash($mounts)
  validate_hash($mount_files)
  validate_hash($mount_entries)
  validate_string($package_name)
  validate_string($service_name)
  validate_string($config_file)
  validate_string($config_file_owner)
  validate_string($config_file_group)
  validate_string($config_file_mode)

  class { '::autofs::install': } ->
  class { '::autofs::config': } ~>
  class { '::autofs::service': } ->
  Class['::autofs']
}
