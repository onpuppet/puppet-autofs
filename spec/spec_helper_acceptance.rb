require 'beaker-rspec'

install_puppet_agent_on hosts, {} unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: module_root, module_name: 'autofs')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: 0
      on host, puppet('module', 'install', 'puppetlabs-concat'), acceptable_exit_codes: 0
    end
  end
end
