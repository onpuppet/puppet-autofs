require 'spec_helper'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir => '/etc/puppet' })
        end

        context "autofs class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('autofs::params') }
          it { is_expected.to contain_class('autofs::install').that_comes_before('autofs::config') }
          it { is_expected.to contain_class('autofs::config') }
          it { is_expected.to contain_class('autofs::service').that_subscribes_to('autofs::config') }

          it { is_expected.to contain_service('autofs') }
          it { is_expected.to contain_package('autofs').with_ensure('present') }
        end

        context "autofs class with mounts" do
          let(:params) {{
              'mounts' => {
              'home' => {
              'remote'     => 'nfs:/export/home',
              'mountpoint' => '/home',
              'options'    => 'hard,rw',
              },
              }
            }}

          it { is_expected.to compile.with_all_deps }

          it { should contain_autofs__mount('home') }
          it { is_expected.to contain_class('autofs::params') }
          it { is_expected.to contain_class('autofs::install').that_comes_before('autofs::config') }
          it { is_expected.to contain_class('autofs::config') }
          it { is_expected.to contain_class('autofs::service').that_subscribes_to('autofs::config') }

          it { is_expected.to contain_service('autofs') }
          it { is_expected.to contain_package('autofs').with_ensure('present') }
        end

        context "autofs with external mount files" do
          let(:params) {{
              'mount_files' => {
                'home' => {
                  'mountpoint' => '/home',
                  'file_source' => 'puppet:///modules/homefolder/auto.home'
                }
              }
            }}

          it { is_expected.to compile.with_all_deps }

          it { should contain_autofs__mountfile('home') }
        end

        context "automount folder in /" do
          let(:params) {{
                'mounts' => {
                  'testfolder' => {
                    'remote'     => 'nfs:/export/folder',
                    'options'    => 'hard,rw',
                    'mountpoint' => '/remote',
                 }
              }
            }}

          it { is_expected.to compile.with_all_deps }
          it { should contain_autofs__mount('testfolder') }
          it { should contain_concat('/etc/auto.master') }
          it { should contain_concat__fragment('auto.testfolder') }
          it { should contain_concat__fragment('/-') }
          it 'should generate the automount configurations' do
            contentmaster = catalogue.resource('concat::fragment', '/-').send(:parameters)[:content]
            contentmaster.should_not be_empty
            contentmaster.should match('/- /etc/auto.testfolder')
            contenttestfolder = catalogue.resource('concat::fragment', 'auto.testfolder').send(:parameters)[:content]
            contenttestfolder.should_not be_empty
            contenttestfolder.should match('remote hard,rw nfs:/export/folder')
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'autofs class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }}

      it { expect { is_expected.to contain_package('autofs') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
