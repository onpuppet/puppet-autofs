# == Define: autofs::mountentry
#
# Populate auto.master with mount entry
#
define autofs::mountentry ($mountpoint, $mountfile, $options = '') {

  if ! defined(Class['autofs']) {
    fail('You must include the autofs base class before using any autofs defined resources')
  }

  if ! defined(Concat[$autofs::config_file]) {
    concat { $autofs::config_file:
      owner  => $autofs::config_file_owner,
      group  => $autofs::config_file_group,
      mode   => $autofs::config_file_mode,
      notify => Service[$autofs::service_name],
    }
  }

  # It is allowed to have two entries with the same mount point
  # so it's not actively denied in the module - but for sanity,
  # you SHOULD keep a single mount point in a single config file
  concat::fragment { $title:
    target  => $autofs::config_file,
    content => "${mountpoint} ${mountfile} ${options}\n",
    order   => 10,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }
}
