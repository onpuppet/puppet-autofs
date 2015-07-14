source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "rspec-puppet-facts"
  gem "ci_reporter_rspec"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "metadata-json-lint"
  gem "puppet-lint"
  gem "puppet-lint-variable_contains_upcase"
  gem "puppet-lint-param-docs"
  gem "puppet-lint-absolute_template_path"
  gem "puppet-lint-unquoted_string-check"
  gem "puppet-lint-strict_indent-check"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
end
