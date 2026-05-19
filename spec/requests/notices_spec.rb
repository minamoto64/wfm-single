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

  describe "GET /notices/:id" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get notice_path(notice)

        expect(response).to have_http_status(:ok)
      end

      it "displays the notice basic information" do
        get notice_path(notice)

        expect(response.body).to include(notice.title)
        expect(response.body).to include(notice.user.name)
        expect(response.body).to include(I18n.l(notice.created_at))
      end

      it "displays the notice level and non-restricted status" do
        get notice_path(notice)

        expect(response.body).to include(I18n.t("enums.notice.level.#{notice.level}"))
        expect(response.body).to include("全員")
      end

      it "displays publication period" do
        get notice_path(notice)

        expect(response.body).to include(I18n.l(notice.start_at))
        expect(response.body).to include(I18n.l(notice.end_at))
      end

      it "displays edit link when the user is the creator" do
        get notice_path(notice)

        expect(response.body).to include(edit_notice_path(notice))
      end

      it "does not display edit link when the user is not the creator" do
        other_notice = create(:notice)

        get notice_path(other_notice)

        expect(response.body).not_to include(edit_notice_path(other_notice))
      end

      it "cannot access a restricted notice" do
        get notice_path(restricted_notice)

        expect(response).to redirect_to notices_path
      end
    end

    context "when the user is an admin" do
      before { sign_in(admin) }

      it "can access a restricted notice" do
        get notice_path(restricted_notice)

        expect(response).to have_http_status(:ok)
      end

      it "displays restricted status" do
        get notice_path(restricted_notice)

        expect(response.body).to include("管理者のみ")
      end

      it "displays edit link when an admin is the creator" do
        get notice_path(restricted_notice)

        expect(response.body).to include(edit_notice_path(restricted_notice))
      end

      it "does not display edit link when an admin is not the creator" do
        get notice_path(notice)

        expect(response.body).not_to include(edit_notice_path(notice))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get notice_path(notice)

        expect(response).to redirect_to new_session_path
      end
    end
  end
end
