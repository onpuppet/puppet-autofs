require 'spec_helper_acceptance'

describe 'autofs class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'autofs':
        mounts => {
          'home' => {
            'remote'     => 'nfs:/export/home',
            'mountpoint' => '/home',
            'options'    => '-hard,rw',
          }
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes:  true)
    end

    describe package('autofs') do
      it { is_expected.to be_installed }
    end

    describe service('autofs') do
      # it { is_expected.to be_enabled } # Broken with debian-8
      it { is_expected.to be_running }
    end

    describe file('/etc/auto._-') do
      mapfile = <<-END
# File managed by puppet, do not edit
/home -hard,rw nfs:/export/home
END
      its(:content) { is_expected.to eq(mapfile) }
    end

    describe file('/etc/auto.master') do
      # rubocop:disable Style/TrailingWhitespace
      master_file = <<-END
# File managed by puppet, do not edit
/- /etc/auto._- 
END
      # This line needs an extra space at the end because puppet writes
      # out "${mountpoint} ${mountfile} ${options}", so when options is
      # empty, there's an extra space at the end
      its(:content) { is_expected.to eq(master_file) }
    end
  end

  context 'with custom mapname and mountentry' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'autofs':
        mount_entries => {
          '/etc/auto.glusterfs' => {
            mountpoint => '/mnt/gluster',
            mountfile  => '/etc/auto.glusterfs',
            options    => '--timeout=600',
          },
        },
        mounts => {
          'gv0' => {
            'mapname'    => 'glusterfs',
            'remote'     => 'gluster:/gv0',
            'mountpoint' => 'gv0',
            'options'    => '-fstype=glusterfs',
          },
          'gv1' => {
            'mapname'    => 'glusterfs',
            'remote'     => 'gluster:/gv1',
            'mountpoint' => 'gv1',
            'options'    => '-fstype=glusterfs',
          },
        },
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes:  true)
    end

    describe package('autofs') do
      it { is_expected.to be_installed }
    end

    describe service('autofs') do
      # it { is_expected.to be_enabled } # Broken with debian-8
      it { is_expected.to be_running }
    end

    describe file('/etc/auto.glusterfs') do
      mapfile = <<-END
# File managed by puppet, do not edit
gv0 -fstype=glusterfs gluster:/gv0
gv1 -fstype=glusterfs gluster:/gv1
END
      its(:content) { is_expected.to eq(mapfile) }
    end

    describe file('/etc/auto.master') do
      master_file = <<-END
# File managed by puppet, do not edit
/mnt/gluster /etc/auto.glusterfs --timeout=600
END
      its(:content) { is_expected.to eq(master_file) }
    end

    describe file('/mnt/gluster') do
      it { is_expected.to be_mounted.with(options: { timeout: 600 }) }
    end
  end
end
