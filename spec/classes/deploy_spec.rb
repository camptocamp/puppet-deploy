require 'spec_helper'

describe 'deploy' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) do
        {
          :private_key => 'DEADBEEF',
          :public_key  => 'BEEFDEAD',
          :pg_role     => false,
        }
      end

      it { should compile.with_all_deps }
    end
  end
end
