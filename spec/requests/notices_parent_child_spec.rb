require "rails_helper"

RSpec.describe "Notices parent-child", type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, admin: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /notices/:id - back link" do
    before { sign_in(user) }

    context "when the notice has no parent" do
      let(:notice) { create(:notice, user: user) }

      it "links back to the index" do
        get notice_path(notice)

        expect(response.body).to include(notices_path)
        expect(response.body).to include("一覧に戻る")
      end
    end

    context "when the notice has a parent" do
      let(:parent) { create(:notice, user: user) }
      let(:child) { create(:notice, user: user, parent: parent) }

      it "links back to the index" do
        get notice_path(child)

        expect(response.body).to include(notices_path)
        expect(response.body).to include("一覧に戻る")
      end
    end
  end

  describe "/GET /notices/:id - timeline" do
    before { sign_in(user) }

    context "when the notice has no children" do
      let(:notice) { create(:notice, user: user) }

      it "renders a timeline including only itself" do
        get notice_path(notice)

        expect(response.body).to include(notice.content.truncate(30))
      end
    end

    context "when viewing a parent notice" do
      let(:parent) { create(:notice, user: user) }
      let!(:child) { create(:notice, user: user, parent: parent) }
      let!(:grandchild) { create(:notice, user: user, parent: child) }

      it "displays all children in the timeline" do
        get notice_path(parent)

        expect(response.body).to include(child.content.truncate(40))
        expect(response.body).to include(grandchild.content.truncate(40))
      end
    end

    context "when viewing a child notice" do
      let(:parent) { create(:notice, user: user) }
      let!(:child) { create(:notice, user: user, parent: parent) }
      let!(:grandchild) { create(:notice, user: user, parent: child) }

      it "displays the parent in the timeline" do
        get notice_path(child)

        expect(response.body).to include(parent.content.truncate(40))
      end

      it "displays sibling notices in the timeline" do
        get notice_path(child)

        expect(response.body).to include(grandchild.content.truncate(40))
      end
    end

    context "when the notice has descendants" do
      let(:parent) { create(:notice, user: user) }
      let!(:child) { create(:notice, user: user, parent: parent) }

      it "marks the currently viewed notice with ★ 現在" do
        get notice_path(parent)

        expect(response.body).to include("★ 現在")
      end

      it "links to other timeline items" do
        get notice_path(parent)

        expect(response.body).to include(notice_path(child))
      end

      it "does not link to the current notice in the timeline" do
        get notice_path(child)

        expect(response.body).not_to include(%(href="#{notice_path(child)}"))
      end
    end

    context "when the notice belongs to a hierarchy" do
      let!(:parent) { create(:notice, user: user, created_at: 2.hours.ago) }
      let!(:child) do
        create(
          :notice,
          user: user,
          parent: parent,
          content: "子お知らせの詳細",
          created_at: 1.hour.ago
        )
      end

      let!(:grandchild) do
        create(
          :notice,
          user: user,
          parent: child,
          content: "孫お知らせの詳細",
          created_at: 30.minutes.ago
        )
      end

      it "displays items in chronological order" do
        get notice_path(parent)

        expect(response.body).to match(/#{child.content}.*#{grandchild.content}/m)
      end
    end

    context "when the notice can be followed up" do
      let(:notice) { create(:notice, user: user) }

      it "includes a link to create a child with parent_id" do
        get notice_path(notice)
        expect(response.body).to include(new_notice_path(parent_id: notice.id))
      end
    end
  end

  describe "GET /notices/new with parent_id" do
    before { sign_in(user) }

    context "when creating a follow-up notice from an existing notice" do
      let(:parent) { create(:notice, user: user) }

      it "responds with HTTP 200 OK" do
        get new_notice_path(parent_id: parent.id)

        expect(response).to have_http_status(:ok)
      end

      it "includes the parent notice id in the form" do
        get new_notice_path(parent_id: parent.id)

        expect(response.body).to include(parent.id.to_s)
      end
    end

    context "when creating a follow-up notice with a non-existent parent notice" do
      it "responds with HTTP 200 OK and ignores the invalid parent_id" do
        get new_notice_path(parent_id: 0)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /notices with parent_id" do
    let!(:parent) { create(:notice, user: user) }
    let(:child_params) do
      {
        notice: {
          title: "子お知らせ",
          content: "子の詳細",
          level: "normal",
          start_at: 1.hour.ago,
          end_at: 1.week.from_now,
          parent_id: parent.id
        }
      }
    end

    context "when creating a follow-up notice" do
      before { sign_in(user) }

      it "creates a notice and associates it with the parent" do
        expect {
          post notices_path, params: child_params
        }.to change(Notice, :count).by(1)

        expect(Notice.last.parent).to eq(parent)
      end

      it "redirects to the child notice page" do
        post notices_path, params: child_params

        expect(response).to redirect_to notice_path(Notice.last)
      end
    end

    context "when creating a root notice" do
      before { sign_in(user) }

      it "creates a notice without a parent" do
        post notices_path, params: {
          notice: {
            title: "ルートお知らせ",
            content: "詳細",
            level: "normal",
            start_at: 1.hour.ago,
            end_at: 1.week.from_now
          }
        }

        expect(Notice.last.parent).to be_nil
      end
    end
  end
end
