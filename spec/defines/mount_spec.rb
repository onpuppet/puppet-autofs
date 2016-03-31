require 'spec_helper'

describe 'autofs::mount', :type => :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/etc/puppet' })
      end

      let :pre_condition do
        'class { "autofs": }'
      end

      let(:title) { 'bin' }

      let(:params) do
        { 'remote'     => 'nfs:/remotedir',
          'mountpoint' => '/localdir',
          'options'    => '-ro,hard'
        }
      end

      it 'should accept valid parameters' do
        is_expected.to contain_concat('/etc/auto._-').with_owner('root')
      end

      it 'should report an error when options are missing - in front' do
        params.merge!({'options' => 'ro,hard'})
        expect { catalogue }.to raise_error(Puppet::Error,
        /Autofs::Mount options string must start with -, and not contain spaces. Got: /)
      end

      it 'should report an error when options contain spaces' do
        params.merge!({'options' => '-ro, hard'})
        expect { catalogue }.to raise_error(Puppet::Error,
        /Autofs::Mount options string must start with -, and not contain spaces. Got: /)
      end
    end
  end
end
