# == Class autofs::service
#
# This class is meant to be called from autofs.
# It ensure the service is running.
#
class autofs::service {

  service { $::autofs::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
