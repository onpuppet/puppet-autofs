# == Define: autofs::mountentry
#
# Populate auto.master with mount entry
#
define autofs::mountentry ($mountpoint, $mountfile, $options = '') {

  concat::fragment { $name:
    ensure  => 'present',
    target  => $autofs::config_file,
    content => "${mountpoint} ${mountfile} ${options}\n",
    order   => 100,
    notify  => Service[$autofs::service_name],
    require => Package[$autofs::package_name],
  }
}
