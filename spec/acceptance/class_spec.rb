require 'spec_helper_acceptance'

describe 'autofs class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'autofs':
        mounts => {
          'home' => {
            'remote'     => 'nfs:/export/home',
            'mountpoint' => '/home',
            'options'    => 'hard,rw',
          },
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('autofs') do
      it { is_expected.to be_installed }
    end

    describe service('autofs') do
      # it { is_expected.to be_enabled } # Broken with debian-8
      it { is_expected.to be_running }
    end
  end
end
