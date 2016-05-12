# == Define: autofs::mount
#
# Add mount point to autofs configuration
#
define autofs::mount ($remote, $mountpoint, $options = '') {

  if ! defined(Class['autofs']) {
    fail('You must include the autofs base class before using any autofs defined resources')
  }

  if $options != '' and $options !~ /-[\S]+?$/ {
    fail("Autofs::Mount options string must start with -, and not contain spaces. Got: ${options}")
  }

  if dirname($mountpoint) == '/' {
    $dirname = '/-'
    $basename = $mountpoint
  } else {
    $dirname = dirname($mountpoint)
    $basename = basename($mountpoint)
  }

  $safe_target_name = regsubst($dirname, '[/:\n\s\*\(\)]|(?:master)', '_', 'GM')

  $mountfile = "/etc/auto.${safe_target_name}"

  # Multiple mounts under the same subdir should only
  # have a single entry in auto.master file
  if ! defined(Concat[$mountfile]) {
    concat { $mountfile:
      owner  => $autofs::config_file_owner,
      group  => $autofs::config_file_group,
      mode   => $autofs::config_file_mode,
      notify => Service[$autofs::service_name],
    }

    concat::fragment { "${mountfile} preamble":
      target  => $mountfile,
      content => "# File managed by puppet, do not edit\n",
      order   => 1,
      notify  => Service[$autofs::service_name],
    }

    # Ensure auto.master is referencing auto.safe_target_name config file (mountfile) and
    # avoid collisions with manually entered mount entries
    if ! defined(Autofs::Mountentry[$mountfile]) {
      autofs::mountentry { $mountfile:
        mountpoint => $dirname,
        mountfile  => $mountfile,
      }
    }
  }

  # Subdir should only get added into the mountfile referenced in auto.master, and not
  # directly in auto.master
  concat::fragment { $title:
    target  => $mountfile,
    content => "${basename} ${options} ${remote}\n",
    order   => 10,
    notify  => Service[$autofs::service_name],
  }
}
