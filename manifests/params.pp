# == Class autofs::params
#
# This class is meant to be called from autofs.
# It sets variables according to platform.
#
class autofs::params {
  $mounts = {
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/auto.master',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  case $::osfamily {
    'Debian'           : {
      $package_name = 'autofs'
      $service_name = 'autofs'
    }
    'RedHat', 'Amazon' : {
      $package_name = 'autofs'
      $service_name = 'autofs'
    }
    default            : {
      fail("${::operatingsystem} not supported")
    }
  }
}
