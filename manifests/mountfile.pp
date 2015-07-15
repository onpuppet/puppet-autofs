# == Define: autofs::mountfile
#
# Provide custom map file containing mounts
#
define autofs::mountfile ($mountpoint, $file_source) {
  $mountfile = "/etc/auto.$title"

  file { $mountfile:
    ensure  => 'present',
    owner   => $autofs::config_file_user,
    group   => $autofs::config_file_group,
    mode    => $autofs::config_file_mode,
    source  => $file_source,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }

  if (!defined(Concat::Fragment[$dirname])) {
    concat::fragment { $dirname:
      ensure  => 'present',
      target  => $autofs::config_file,
      content => "${dirname} ${mountfile}\n",
      order   => 100,
      notify  => Service[$autofs::service_name],
    }
  }
}
