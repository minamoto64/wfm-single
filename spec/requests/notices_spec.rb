require 'rails_helper'

RSpec.describe "Notices", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let!(:notice) { create(:notice, user: user) }
  let!(:restricted_notice) { create(:notice, user: admin, restricted: true) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
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

      it "ignores unauthorized creator user filters and returns unfiltered results" do
        other_notice = create(:notice, user: admin, restricted: false)

        get notices_path, params: {
          q: {
            user_email_address_cont: admin.email_address,
            user_admin_eq: true
          }
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(notice.title, other_notice.title)
      end

      it "shows the (limit+1)th notice only on page 2" do
        limit = Pagy::DEFAULT[:items]
        (1..limit).each { |i| create(:notice, user: user, start_at: i.minutes.ago) }
        target_notice = create(:notice, user: user, start_at: 1.year.ago, title: "2ページ目のお知らせ")

        get notices_path
        expect(response.body).not_to include(target_notice.title)

        get notices_path, params: { page: 2 }
        expect(response.body).to include(target_notice.title)
      end

      it "uses full-page navigation for user links inside turbo frame" do
        get notices_path

        expect(response.body).to include('data-turbo-frame="_top"')
        expect(response.body).to include(user_path(notice.user))
      end

      it "renders related notices under the parent notice row" do
        related_notice = create(:notice, user: user, parent: notice, title: "関連お知らせの内容")

        get notices_path

        expect(response.body).to include("関連")
        expect(response.body).to include(related_notice.title)
      end

      it "renders sibling notices as related, not just direct children" do
        first_sibling_notice = create(:notice, user: user, parent: notice, title: "関連お知らせA")
        second_sibling_notice = create(:notice, user: user, parent: notice, title: "関連お知らせB")

        get notices_path

        expect(response.body).to include(first_sibling_notice.title)
        expect(response.body).to include(second_sibling_notice.title)
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

        expect(response).to redirect_to login_path
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

        expect(response).to redirect_to login_path
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

        expect(response).to redirect_to login_path
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

      it "does not create a Notice with invalid params" do
        expect {
          post notices_path, params: { notice: { title: nil } }
        }.not_to change(Notice, :count)
      end

      it "re-renders the new template with invalid params" do
        post notices_path, params: { notice: { title: nil } }

        expect(response).to have_http_status(:unprocessable_content)
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

        expect(response).to redirect_to login_path
      end
    end
  end

  describe "POST /notices (with images)" do
    subject(:perform_request) do
      post notices_path, params: {
        notice: attributes_for(:notice).merge(images: images)
      }
    end

    before { sign_in(user) }

    context "with a valid image" do
      let(:images) { [ valid_image ] }

      it "creates a notice with images" do
        expect { perform_request }
          .to change(Notice, :count).by(1)

        expect(response).to redirect_to(notice_path(Notice.last))
        expect(Notice.last.images).to be_attached
      end
    end

    context "with an invalid file" do
      let(:images) { [ invalid_file ] }

      it "does not create a notice" do
        expect { perform_request }
          .not_to change(Notice, :count)
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
      let(:other_user) { create(:user) }

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

        expect(response).to redirect_to login_path
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
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "cannot update a restricted notice and redirects to the index template" do
        patch notice_path(restricted_notice),
          params: { notice: { content: "追記" } }

        expect(restricted_notice.reload.content).not_to eq("追記")
        expect(response).to redirect_to notices_path
      end
    end

    context "when the user is not the creator" do
      let(:other_user) { create(:user) }

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

        expect(response).to redirect_to login_path
      end
    end
  end

  describe "PATCH /notices/:id (with images)" do
    before { sign_in(user) }

    it "updates a notice with images" do
      patch notice_path(notice), params: {
        notice: { images: [ valid_image ] }
      }

      expect(response).to redirect_to(notice_path(notice))
      expect(notice.reload.images).to be_attached
    end
  end
end
