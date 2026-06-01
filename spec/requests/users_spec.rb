require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let!(:admin) { create(:user, admin: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /users" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get users_path

        expect(response).to have_http_status(:ok)
      end

      it "displays the users list" do
        get users_path

        expect(response.body).to include(user.name)
        expect(response.body).to include(admin.name)
        expect(response.body).to include(I18n.t("users.admin.#{user.admin?}"))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get users_path

        expect(response).to redirect_to new_session_path
      end
    end
  end
end
