require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  let(:admin_user) { create(:user, name: 'Admin User', admin: true) }
  let(:normal_user) { create(:user, name: 'Normal User', admin: false) }

  before do
    post session_path, params: { email_address: login_user.email_address, password: login_user.password }
    get root_path
  end

  context 'when logged in as admin user' do
    let(:login_user) { admin_user }

    it 'shows user name' do
      expect(response.body).to include('こんにちは、Admin User')
    end

    it 'shows admin label' do
      expect(response.body).to include('管理者')
    end
  end

  context 'when logged in as normal user' do
    let(:login_user) { normal_user }

    it 'shows user name' do
      expect(response.body).to include('こんにちは、Normal User')
    end

    it 'does not show admin label' do
      expect(response.body).not_to include('管理者')
    end
  end
end
