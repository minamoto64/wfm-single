require 'rails_helper'

RSpec.describe "Notices", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let!(:notice) { create(:notice, user: user) }
  let!(:restricted_notice) { create(:notice, user: admin, restricted: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /notices" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get notices_path

        expect(response).to have_http_status(:ok)
      end

      it "displays the notices list" do
        get notices_path

        expect(response.body).to include(notice.title)
        expect(response.body).to include(I18n.t("enums.notice.level.#{notice.level}"))
        expect(response.body).to include(notice.user.name)
      end

      it "does not display restricted notices when the user is not an admin" do
        get notices_path

        expect(response.body).not_to include(restricted_notice.title)
      end
    end

    context "when the user is admin" do
      before { sign_in(admin) }

      it "displays all notices including restricted notices" do
        get notices_path

        expect(response.body).to include(notice.title)
        expect(response.body).to include(restricted_notice.title)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get notices_path

        expect(response).to redirect_to new_session_path
      end
    end
  end
end
