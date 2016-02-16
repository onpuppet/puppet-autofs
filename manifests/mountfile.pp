# == Define: autofs::mountfile
#
# Provide custom map file containing mounts
#
define autofs::mountfile ($mountpoint, $file_source) {
  $mountfile = "/etc/auto.${title}"

  file { $mountfile:
    ensure  => 'present',
    owner   => $autofs::config_file_owner,
    group   => $autofs::config_file_group,
    mode    => $autofs::config_file_mode,
    source  => $file_source,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }

  autofs::mountentry { $mountfile:
    mountpoint => $mountpoint,
    mountfile  => $mountfile,
  }
}
