require 'spec_helper'

describe 'pam_radius_auth' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'pam_radius_secret' => 's3cret',
          'pam_radius_servers' => ['first.server.gov', 'second.serv'],
          'pam_radius_timeout' => 30,
        }
      end

      it { is_expected.to compile }
    end
  end
end
