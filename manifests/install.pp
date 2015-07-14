# == Class autofs::install
#
# This class is called from autofs for install.
#
class autofs::install {

  package { $::autofs::package_name:
    ensure => present,
  }
}
