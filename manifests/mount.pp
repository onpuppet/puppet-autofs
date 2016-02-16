# == Define: autofs::mount
#
# Add mount point to autofs configuration
#
define autofs::mount ($remote, $mountpoint, $options = '') {
  if (dirname($mountpoint) == '/') {
    $dirname = '/-'
    $basename = $mountpoint
  } else {
    $dirname = dirname($mountpoint)
    $basename = basename($mountpoint)
  }

  $mountfile = "/etc/auto.${title}"

  if (!defined(Concat[$mountfile])) {
    concat { $mountfile:
      owner  => $autofs::config_file_owner,
      group  => $autofs::config_file_group,
      mode   => $autofs::config_file_mode,
      notify => Service[$autofs::service_name],
    }

    concat::fragment { "${mountfile} preamble":
      ensure  => present,
      target  => $mountfile,
      content => "# File managed by puppet, do not edit\n",
      order   => '01',
      notify  => Service[$autofs::service_name],
    }
  }

  concat::fragment { "auto.${title}":
    ensure  => present,
    target  => $mountfile,
    content => "${basename} ${options} ${remote}\n",
    order   => 100,
    notify  => Service[$autofs::service_name],
  }

  # Allow multiple mounts under the same parent dir
  if (!defined(Autofs::Mountentry[$name])) {
    autofs::mountentry { $name:
      mountpoint => $dirname,
      mountfile  => $mountfile,
    }
  }

}
