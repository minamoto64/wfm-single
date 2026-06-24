require "rails_helper"

RSpec.describe "Notices search", type: :request do
  let(:admin)        { create(:user, name: "管理者", admin: true) }
  let(:regular_user) { create(:user, name: "一般ユーザー", admin: false) }

  let!(:public_notice) do
    create(:notice, title: "公開お知らせ", content: "誰でも閲覧可能なお知らせ", user: admin)
  end
  let!(:restricted_notice) do
    create(:notice, title: "限定お知らせ", content: "管理者専用コンテンツ", restricted: true, user: admin)
  end
  let!(:user_notice) do
    create(:notice, title: "ユーザーお知らせ", content: "一般ユーザーの作業", user: regular_user)
  end

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /notices" do
    context "when signed in as admin" do
      before { sign_in(admin) }

      it "returns all records including restricted ones when no search params are given" do
        get notices_path

        expect(response.body).to include(public_notice.title, restricted_notice.title, user_notice.title)
      end

      it "filters by title keyword" do
        get notices_path, params: { q: { title_cont: "公開" } }

        expect(response.body).to include(public_notice.title)
        expect(response.body).not_to include(restricted_notice.title, user_notice.title)
      end

      it "filters by content keyword via title_or_content_cont" do
        get notices_path, params: { q: { title_or_content_cont: "管理者専用" } }

        expect(response.body).to include(restricted_notice.title)
        expect(response.body).not_to include(public_notice.title, user_notice.title)
      end

      it "filters by creator name" do
        get notices_path, params: { q: { user_name_cont: "一般" } }

        expect(response.body).to include(user_notice.title)
        expect(response.body).not_to include(public_notice.title, restricted_notice.title)
      end

      it "filters by restricted status" do
        get notices_path, params: { q: { restricted_eq: true } }

        expect(response.body).to include(restricted_notice.title)
        expect(response.body).not_to include(public_notice.title, user_notice.title)
      end

      it "filters by multiple conditions combined" do
        get notices_path, params: { q: { user_name_cont: "管理者", restricted_eq: true } }

        expect(response.body).to include(restricted_notice.title)
        expect(response.body).not_to include(public_notice.title, user_notice.title)
      end

      it "filters by level" do
        normal_notice = create(:notice, title: "通常お知らせ", level: "normal", user: admin)

        get notices_path, params: { q: { level_eq: "important" } }

        expect(response.body).to include(public_notice.title, restricted_notice.title)
        expect(response.body).not_to include(normal_notice.title)
      end
    end

    context "when signed in as regular user" do
      before { sign_in(regular_user) }

      it "returns only non-restricted notices when no search params are given" do
        get notices_path

        expect(response.body).to include(public_notice.title, user_notice.title)
        expect(response.body).not_to include(restricted_notice.title)
      end

      it "filters by title keyword among visible notices only" do
        get notices_path, params: { q: { title_cont: "公開" } }

        expect(response.body).to include(public_notice.title)
        expect(response.body).not_to include(user_notice.title, restricted_notice.title)
      end

      it "filters by creator name among visible notices only" do
        get notices_path, params: { q: { user_name_cont: "一般" } }

        expect(response.body).to include(user_notice.title)
        expect(response.body).not_to include(public_notice.title)
      end

      it "cannot see restricted notices even when passing restricted_eq: true" do
        get notices_path, params: { q: { restricted_eq: true } }

        expect(response.body).not_to include(restricted_notice.title)
      end
    end
  end
end
