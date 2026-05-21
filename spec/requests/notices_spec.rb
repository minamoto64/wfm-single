require 'rails_helper'

RSpec.describe "Notices", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let!(:notice) { create(:notice, user: user) }
  let!(:restricted_notice) { create(:notice, user: admin, restricted: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  def valid_params
    {
      notice: {
        title: "テストお知らせ",
        content: "テストタスクの詳細",
        level: "important",
        start_at: 1.hour.ago,
        end_at: 1.week.from_now
      }
    }
  end

  def child_params
    {
      notice: {
        title: "子テストタスク",
        content: "子テストタスクの詳細",
        level: "important",
        start_at: 1.hour.ago,
        end_at: 1.week.from_now
      }
    }
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

  describe "GET /notices/new" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get new_notice_path

        expect(response).to have_http_status(:ok)
      end

      it "does not display restricted check box" do
        get new_notice_path

        expect(response.body).not_to include("管理者のみ")
      end
    end

    context "when the user is an admin" do
      before { sign_in(admin) }

      it "displays restricted check box" do
        get new_notice_path

        expect(response.body).to include("管理者のみ")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get new_notice_path

        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "POST /notices" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "creates a Notice with valid params" do
        expect {
          post notices_path, params: valid_params
        }.to change(Notice, :count).by(1)
      end

      it "redirects to the show page with valid params" do
        post notices_path, params: valid_params

        expect(response).to redirect_to(notice_path(Notice.last))
      end

      it "records the user who created it" do
        post notices_path, params: valid_params

        expect(Notice.last.user).to eq(user)
      end

      it "creates a child notice" do
        parent = create(:notice, user: user)

        expect {
          post notices_path, params: { notice: child_params[:notice].merge(parent_id: parent.id) }
        }.to change(Notice, :count).by(1)
      end

      it "associates the parent notice correctly" do
        parent = create(:notice, user: user)

        post notices_path, params: { notice: child_params[:notice].merge(parent_id: parent.id) }

        expect(Notice.last.parent).to eq(parent)
      end

      it "does not create a Notice with invalid params" do
        expect {
          post notices_path, params: { notice: { title: nil } }
        }.not_to change(Notice, :count)
      end

      it "re-renders the new template with invalid params" do
        post notices_path, params: { notice: { title: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "ignores restricted parameter" do
        post notices_path, params: { notice: child_params[:notice].merge(restricted: true) }

        expect(Notice.last.restricted).to be(false)
      end
    end

    context "when the user is an admin" do
      before { sign_in(admin) }

      it "allows to set restricted" do
        post notices_path, params: { notice: child_params[:notice].merge(restricted: true) }

        expect(Notice.last.restricted).to be(true)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post notices_path, params: {}

        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "GET /notices/:id/edit" do
    context "when the user is the creator" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get edit_notice_path(notice)

        expect(response).to have_http_status(:ok)
      end

      it "does not display restricted check box" do
        get edit_notice_path(notice)

        expect(response.body).not_to include("管理者のみ")
      end

      it "cannot access a restricted notice and redirects to the index page" do
        get edit_notice_path(restricted_notice)

        expect(response).to redirect_to notices_path
      end
    end

    context "when the user is not the creator" do
      before { sign_in(other_user) }

      it "redirects to the show page" do
        get edit_notice_path(notice)

        expect(response).to redirect_to notice_path(notice)
      end
    end

    context "when the user is an admin and the creator" do
      before { sign_in(admin) }

      it "can access a restricted notice" do
        get edit_notice_path(restricted_notice)

        expect(response).to have_http_status(:ok)
      end

      it "displays restricted check box" do
        get edit_notice_path(restricted_notice)

        expect(response.body).to include("管理者のみ")
      end
    end

    context "when the user is an admin but not the creator" do
      before { sign_in(admin) }

      it "redirects to the show page" do
        get edit_notice_path(notice)

        expect(response).to redirect_to notice_path(notice)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get edit_notice_path(notice)

        expect(response).to redirect_to new_session_path
      end
    end
  end

  describe "PATCH /notices/:id" do
    context "when the user is the creator" do
      before { sign_in(user) }

      it "updates the notice and redirects to the show page with valid params" do
        patch notice_path(notice),
          params: { notice: { content: "追記" } }

        expect(notice.reload.content).to eq("追記")
        expect(response).to redirect_to notice_path(notice)
      end

      it "does not update the notice and re-renders the edit template with invalid params" do
        patch notice_path(notice), params: { notice: { title: nil } }

        expect(notice.reload.title).not_to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "cannot update a restricted notice and redirects to the index template" do
        patch notice_path(restricted_notice),
          params: { notice: { content: "追記" } }

        expect(restricted_notice.reload.content).not_to eq("追記")
        expect(response).to redirect_to notices_path
      end
    end

    context "when the user is not the creator" do
      before { sign_in(other_user) }

      it "does not update the notice and redirects to the show page" do
        patch notice_path(notice), params: { notice: { content: "追記" } }

        expect(notice.reload.content).not_to eq("追記")
        expect(response).to redirect_to notice_path(notice)
      end
    end

    context "when the usee is an admin and the creator" do
      before { sign_in(admin) }

      it "updates the restricted notice and redirects to the show page" do
        patch notice_path(restricted_notice), params: { notice: { content: "追記" } }

        expect(restricted_notice.reload.content).to eq("追記")
        expect(response).to redirect_to notice_path(restricted_notice)
      end
    end

    context "when the user is an admin but not the creator" do
      before { sign_in(admin) }

      it "does not update the notice and redirects to the show page" do
        patch notice_path(notice), params: { notice: { content: "追記" } }

        expect(notice.reload.content).not_to eq("追記")
        expect(response).to redirect_to notice_path(notice)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        patch notice_path(notice), params: {}

        expect(response).to redirect_to new_session_path
      end
    end
  end
end
