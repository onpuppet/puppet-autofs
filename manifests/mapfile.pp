# == Define: autofs::mapfile
#
# Provide custom map file containing mounts
#
define autofs::mapfile ($directory, $source = '', $template = '') {
  $manage_file_source = $source ? {
    ''      => undef,
    default => $source,
  }

  $manage_file_content = $template ? {
    ''      => undef,
    default => template($template),
  }

  file { "/etc/auto.$title":
    ensure  => 'present',
    path    => "/etc/auto.$title",
    owner   => $autofs::config_file_user,
    group   => $autofs::config_file_group,
    mode    => $autofs::config_file_mode,
    source  => $manage_file_source,
    content => $manage_file_content,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }

  if (!defined(Concat::Fragment[$dirname])) {
    concat::fragment { $dirname:
      ensure  => present,
      target  => $autofs::config_file,
      content => "${dirname} ${mountfile}\n",
      order   => 100,
      notify  => Service[$autofs::service_name],
    }
  }
}
