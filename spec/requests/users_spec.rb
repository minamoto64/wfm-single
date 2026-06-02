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

  describe "GET /users/:id" do
    let(:interaction) do
      create(
        :interaction,
        user: user,
        request_content: "テスト",
        occurred_at: Time.zone.local(2025, 1, 10, 14, 30)
      )
    end

    context "when the user is logged in" do
      before do
        sign_in(user)
        interaction
      end

      it "responds with HTTP 200 OK" do
        get user_path(user)

        expect(response).to have_http_status(:ok)
      end

      it "displays the user basic information" do
        get user_path(user)

        expect(response.body).to include(user.name)
        expect(response.body).to include(user.email_address)
        expect(response.body).to include(I18n.l(user.created_at))
        expect(response.body).to include(I18n.l(user.updated_at))
      end

      it "displays user role" do
        get user_path(user)

        expect(response.body).to include("一般")
      end

      it "displays admin role for admin users" do
        get user_path(admin)

        expect(response.body).to include("管理者")
      end

      it "displays related interactions" do
        get user_path(user)

        expect(response.body).to include(interaction.request_content)
        expect(response.body).to include(I18n.l(interaction.occurred_at))
        expect(response.body).to include(interaction_path(interaction))
      end

      it "does not display edit link for non-admin users" do
        get user_path(user)

        expect(response.body).not_to include(edit_user_path(user))
      end
    end

    context "when the user is an admin" do
      before do
        sign_in(admin)
      end

      it "displays edit link" do
        get user_path(user)

        expect(response.body).to include(edit_user_path(user))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get user_path(user)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
