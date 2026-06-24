require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let!(:admin) { create(:user, admin: true) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
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

        expect(response).to redirect_to login_path
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

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /users/new" do
    context "when the current user is an admin" do
      before { sign_in(admin) }

      it "responds with HTTP 200 OK" do
        get new_user_path

        expect(response).to have_http_status(:ok)
      end

      it "renders the new template" do
        get new_user_path

        expect(response.body).to include("氏名")
        expect(response.body).to include("メールアドレス")
        expect(response.body).to include("パスワード")
        expect(response.body).to include("管理者権限を付与")
      end
    end

    context "when the current user is not an admin" do
      before { sign_in(user) }

      it "redirects to the root page" do
        get new_user_path

        expect(response).to redirect_to root_path
      end

      it "sets an alert message" do
        get new_user_path

        expect(flash[:alert]).to eq("管理者権限が必要です")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get new_user_path

        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          name: "John Doe",
          email_address: "john@example.com",
          password: "password123"
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          name: "",
          email_address: "",
          password: ""
        }
      }
    end

    context "when the current user is an admin" do
      before { sign_in(admin) }

      it "creates a User with valid params" do
        expect {
          post users_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "redirects to the show page with valid params" do
        post users_path, params: valid_params

        expect(response).to redirect_to(user_path(User.last))
      end

      it "sets a success notice" do
        post users_path, params: valid_params

        expect(flash[:notice]).to eq("従業員を登録しました")
      end

      it "re-renders the new template with invalid params" do
        post users_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the current user is not an admin" do
      before { sign_in(user) }

      it "does not create a user" do
        expect {
          post users_path, params: valid_params
        }.not_to change(User, :count)
      end

      it "redirects to the root page" do
        post users_path, params: valid_params

        expect(response).to redirect_to root_path
      end

      it "sets an alert message" do
        post users_path, params: valid_params

        expect(flash[:alert]).to eq("管理者権限が必要です")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post users_path, params: {}

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /users/:id/edit" do
    context "when the current user is an admin" do
      before { sign_in(admin) }

      it "responds with HTTP 200 OK" do
        get edit_user_path(user)

        expect(response).to have_http_status(:ok)
      end

      it "renders the edit template" do
        get edit_user_path(user)

        expect(response.body).to include("氏名")
        expect(response.body).to include("メールアドレス")
        expect(response.body).to include("パスワード（変更する場合のみ）")
        expect(response.body).to include("管理者権限を付与")
      end
    end

    context "when the current user is not an admin" do
      before { sign_in(user) }

      it "redirects to the root page" do
        get edit_user_path(user)

        expect(response).to redirect_to(root_path)
      end

      it "sets an alert message" do
        get edit_user_path(user)

        expect(flash[:alert]).to eq("管理者権限が必要です")
      end
    end
  end

  describe "PATCH /users/:id" do
    let(:valid_params) do
      {
        user: {
          name: "Updated Name",
          email_address: "updated@example.com"
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          name: "",
          email_address: ""
        }
      }
    end

    context "when the current user is an admin" do
      before { sign_in(admin) }

      it "updates the user" do
        patch user_path(user), params: valid_params

        expect(user.reload.name).to eq("Updated Name")
        expect(user.reload.email_address).to eq("updated@example.com")
      end

      it "redirects to the user page" do
        patch user_path(user), params: valid_params

        expect(response).to redirect_to user_path(user)
      end

      it "sets a success notice" do
        patch user_path(user), params: valid_params

        expect(flash[:notice]).to eq("従業員情報を更新しました")
      end

      it "does not update the password when password is blank" do
        old_digest = user.password_digest

        patch user_path(user), params: {
          user: {
            name: "Updated Name",
            password: ""
          }
        }

        expect(user.reload.password_digest).to eq(old_digest)
      end

      it "does not update the user with invalid parameters" do
        original_name = user.name

        patch user_path(user), params: invalid_params

        expect(user.reload.name).to eq(original_name)
      end

      it "re-renders the edit template with invalid params" do
        patch user_path(user), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the current user is not an admin" do
      before { sign_in(user) }

      it "does not update the user" do
        original_name = user.name

        patch user_path(user), params: valid_params

        expect(user.reload.name).to eq(original_name)
      end

      it "redirects to the root page" do
        patch user_path(user), params: valid_params

        expect(response).to redirect_to(root_path)
      end

      it "sets an alert message" do
        patch user_path(user), params: valid_params

        expect(flash[:alert]).to eq("管理者権限が必要です")
      end
    end
  end
end
