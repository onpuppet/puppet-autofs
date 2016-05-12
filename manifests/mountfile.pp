# == Define: autofs::mountfile
#
# Provide custom map file containing mounts
#
define autofs::mountfile ($mountpoint, $file_source, $file_mode = $autofs::config_file_mode, $options = '') {

  if ! defined(Class['autofs']) {
    fail('You must include the autofs base class before using any autofs defined resources')
  }

  $safe_target_name = regsubst($title, '[/:\n\s\*\(\)]', '_', 'GM')

  $mountfile = "/etc/auto.${safe_target_name}"

  file { $mountfile:
    ensure  => 'present',
    owner   => $autofs::config_file_owner,
    group   => $autofs::config_file_group,
    mode    => $file_mode,
    source  => $file_source,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }

  autofs::mountentry { $mountfile:
    mountpoint => $mountpoint,
    mountfile  => $mountfile,
    options    => $options,
  }
}
