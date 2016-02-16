# == Class autofs::params
#
# This class is meant to be called from autofs.
# It sets variables according to platform.
#
class autofs::params {
  $mounts = {
  }

  $mount_files = {
  }

  $mount_entries = {
  }

  $config_file = $::operatingsystem ? {
    'Archlinux' => '/etc/autofs/auto.master',
    default     => '/etc/auto.master',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0755',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  case $::osfamily {
    'Debian', 'Archlinux', 'RedHat', 'Amazon' : {
      $package_name = 'autofs'
      $service_name = 'autofs'
    }
    default            : {
      fail("${::operatingsystem} not supported")
    }
  }
}
