require 'spec_helper'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(
            concat_basedir: '/etc/puppet'
          )
        end

        master_file = os =~ %r{archlinux} ? '/etc/autofs/auto.master' : '/etc/auto.master'

        context 'autofs class without any parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('autofs::params') }
          it { is_expected.to contain_class('autofs::config') }
          it { is_expected.to contain_service('autofs') }
          it { is_expected.to contain_package('autofs').with_ensure('present') }
        end

        context 'autofs class with mounts' do
          let(:params) do
            {
              'mounts' => {
                'home' => {
                  'remote'     => 'nfs:/export/home',
                  'mountpoint' => '/home',
                  'options'    => '-hard,rw'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_autofs__mount('home') }
          it { is_expected.to contain_class('autofs::params') }
          it { is_expected.to contain_class('autofs::config') }
          it { is_expected.to contain_service('autofs') }
          it { is_expected.to contain_package('autofs').with_ensure('present') }
        end

        context 'autofs with external mount files' do
          let(:params) do
            {
              'mount_files' => {
                'home' => {
                  'mountpoint' => '/home',
                  'file_source' => 'puppet:///modules/homefolder/auto.home',
                  'file_mode' => '0644'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mountfile('home') }
          it { is_expected.to contain_file('/etc/auto.home').with('mode' => '0644') }
        end

        context 'automount folder in nested directory structure' do
          let(:params) do
            {
              'mounts' => {
                'testfolder1' => {
                  'remote'     => 'nfs:/export/folder1',
                  'options'    => '-hard,rw',
                  'mountpoint' => '/remote/a/b/folder1'
                },
                'testfolder2' => {
                  'remote'     => 'nfs:/export/folder2',
                  'options'    => '-hard,rw',
                  'mountpoint' => '/remote/a/b/folder2'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mount('testfolder1') }
          it { is_expected.to contain_concat(master_file) }
          it { is_expected.to contain_autofs__mountentry('/etc/auto._remote_a_b') }
          it { is_expected.to contain_concat__fragment('/etc/auto._remote_a_b').with_content(%r{\/remote\/a\/b \/etc\/auto._remote_a_b}).with_target(master_file) }
          it { is_expected.to contain_concat__fragment('testfolder1').with_content(%r{^folder1 -hard,rw nfs:\/export\/folder1$}).with_target('/etc/auto._remote_a_b') }
          it { is_expected.to contain_concat__fragment('testfolder2').with_content(%r{^folder2 -hard,rw nfs:\/export\/folder2$}).with_target('/etc/auto._remote_a_b') }
        end

        context 'name collision on master' do
          let(:params) do
            {
              'mounts' => {
                'master' => {
                  'remote'     => 'nfs:/export/folder1',
                  'options'    => '-hard,rw',
                  'mountpoint' => '/master/master'
                }
              }
            }
          end
          it { is_expected.to contain_concat('/etc/auto.__') }
          it { is_expected.to contain_concat__fragment('/etc/auto.__').with_content(%r{\/master \/etc\/auto.__}).with_target(master_file) }
          it { is_expected.to contain_concat__fragment('master').with_content(%r{^master -hard,rw nfs:\/export\/folder1$}).with_target('/etc/auto.__') }
        end

        context 'supply options to auto.master' do
          let(:params) do
            {
              'mount_entries' => {
                # Resource name match generated name from Mount['misc']
                '/etc/auto._misc' => {
                  'mountpoint' => '/misc',
                  'mountfile' => '/etc/auto._misc', # Matched to auto generated name from Mount['misc']
                  'options' => '--timeout=300'
                }
              },
              'mounts' => {
                'misc' => {
                  'remote' => 'nfs:/export/misc/stuff',
                  'mountpoint' => '/misc/stuff'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mount('misc') }
          it { is_expected.to contain_concat(master_file) }
          it { is_expected.to contain_autofs__mountentry('/etc/auto._misc') }
          it { is_expected.to contain_concat__fragment('/etc/auto._misc').with_content(%r{misc \/etc\/auto._misc --timeout=300}).with_target(master_file) }
          it { is_expected.to contain_concat__fragment('misc').with_content(%r{^stuff  nfs:\/export\/misc\/stuff$}).with_target('/etc/auto._misc') }
        end

        context 'automount folders in /' do
          let(:params) do
            {
              'mounts' => {
                'testfolder1' => {
                  'remote'     => 'nfs:/export/folder1',
                  'options'    => '-hard,rw',
                  'mountpoint' => '/remote'
                },
                'testfolder2' => {
                  'remote'     => 'nfs:/export/folder2',
                  'options'    => '-hard,rw',
                  'mountpoint' => '/remote2'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mount('testfolder1') }
          it { is_expected.to contain_concat(master_file) }
          it { is_expected.to contain_autofs__mountentry('/etc/auto._-') }
          it { is_expected.to contain_concat__fragment('/etc/auto._-').with_content(%r{- \/etc\/auto._-}).with_target(master_file) }
          it { is_expected.to contain_concat__fragment('testfolder1').with_content(%r{^\/remote -hard,rw nfs:\/export\/folder1$}).with_target('/etc/auto._-') }
          it { is_expected.to contain_concat__fragment('testfolder2').with_content(%r{^\/remote2 -hard,rw nfs:\/export\/folder2$}).with_target('/etc/auto._-') }
        end

        context 'autofs with custom mount entry' do
          let(:params) do
            {
              'mount_entries' => {
                'home' => {
                  'mountpoint' => '/home',
                  'mountfile' => '/opt/auto.home',
                  'options' => '-t 60'
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mountentry('home') }
          it { is_expected.to contain_concat__fragment('home').with_content(%r{^\/home \/opt\/auto.home -t 60$}).with_target(master_file) }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'autofs class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          osfamily:        'Solaris',
          operatingsystem: 'Nexenta'
        }
      end
      it { expect { is_expected.to contain_package('autofs') }.to raise_error(Puppet::Error, %r{Nexenta not supported}) }
    end
  end
end
