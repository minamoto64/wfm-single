require "rails_helper"

RSpec.describe "Restricted content visibility", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:user)  { create(:user) }

  before { sign_in(user) }

  describe "notice timeline (GET /notices/:id)" do
    it "does not expose a restricted sibling notice's content" do
      root = create(:notice, user: admin, restricted: false)
      create(:notice, user: admin, restricted: true, parent: root, content: "来月の値上げ幅について")

      get notice_path(root)

      expect(response.body).not_to include("来月の値上げ幅について")
    end
  end

  describe "task timeline (GET /tasks/:id)" do
    it "does not expose a restricted sibling task's description" do
      root = create(:task, user: admin, restricted: false)
      create(:task, user: admin, restricted: true, parent: root, description: "未公開キャンペーンの準備")

      get task_path(root)

      expect(response.body).not_to include("未公開キャンペーンの準備")
    end
  end

  describe "creating a follow-up under a restricted record" do
    context "with a notice" do
      let(:parent) { create(:notice, user: admin, restricted: true) }
      let(:child) do
        sign_in(admin)
        post notices_path, params: {
          parent_id: parent.id,
          notice: attributes_for(:notice).merge(title: "続報", content: "上記の件の続き", restricted: "0")
        }
        Notice.find_by!(title: "続報")
      end

      it "stays restricted even when the admin leaves the checkbox off" do
        expect(child.restricted).to be(true)
      end

      it "is not reachable by a non-admin" do
        target = child
        sign_in(user)
        get notice_path(target)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a task" do
      let(:parent) { create(:task, user: admin, restricted: true) }
      let(:child) do
        sign_in(admin)
        post tasks_path, params: {
          parent_id: parent.id,
          task: attributes_for(:task).merge(title: "続報", description: "続き", restricted: "0"),
          assignee_ids: [ admin.id ]
        }
        Task.find_by!(title: "続報")
      end

      it "stays restricted even when the admin leaves the checkbox off" do
        expect(child.restricted).to be(true)
      end

      it "is not reachable by a non-admin" do
        target = child
        sign_in(user)
        get task_path(target)

        expect(response).to have_http_status(:not_found)
      end

      # 親から継承した restricted は task の before_validation で立つため、
      # TaskForm 側の担当者チェックがその前に走ると素通りして500になる。
      it "rejects a non-admin assignee even though restricted is only inherited" do
        parent_task = parent
        sign_in(admin)
        params = {
          parent_id: parent_task.id,
          task: attributes_for(:task).merge(title: "継承続報", description: "続き"),
          assignee_ids: [ user.id ]
        }

        expect { post tasks_path, params: params }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("管理者以外を担当者に指定できません")
      end
    end
  end

  describe "cross-model related sections" do
    it "does not expose a restricted task linked to a visible notice" do
      notice = create(:notice, user: admin, restricted: false)
      restricted_task = create(:task, user: admin, restricted: true, title: "非公開タスク")
      notice.tasks << restricted_task

      get notice_path(notice)

      expect(response.body).not_to include("非公開タスク")
    end

    it "does not expose a restricted notice linked to a visible task" do
      task = create(:task, user: admin, restricted: false)
      restricted_notice = create(:notice, user: admin, restricted: true, title: "非公開のお知らせ")
      task.notices << restricted_notice

      get task_path(task)

      expect(response.body).not_to include("非公開のお知らせ")
    end

    it "does not expose a restricted notice linked to a visible interaction" do
      interaction = create(:interaction)
      restricted_notice = create(:notice, user: admin, restricted: true, title: "非公開のお知らせ2")
      interaction.notices << restricted_notice

      get interaction_path(interaction)

      expect(response.body).not_to include("非公開のお知らせ2")
    end

    it "does not expose a restricted task linked to a visible interaction" do
      interaction = create(:interaction)
      restricted_task = create(:task, user: admin, restricted: true, title: "非公開タスク2")
      interaction.tasks << restricted_task

      get interaction_path(interaction)

      expect(response.body).not_to include("非公開タスク2")
    end
  end

  describe "index related list" do
    it "does not expose a restricted sibling notice's title or content" do
      root = create(:notice, user: admin, restricted: false)
      create(:notice, user: admin, restricted: true, parent: root,
        title: "非公開のお知らせ件名", content: "非公開のお知らせ内容")

      get notices_path

      expect(response.body).not_to include("非公開のお知らせ件名")
      expect(response.body).not_to include("非公開のお知らせ内容")
    end

    it "does not expose a restricted sibling task's title or description" do
      root = create(:task, user: admin, restricted: false)
      create(:task, user: admin, restricted: true, parent: root,
        title: "非公開タスク件名", description: "非公開タスク内容")

      get tasks_path

      expect(response.body).not_to include("非公開タスク件名")
      expect(response.body).not_to include("非公開タスク内容")
    end
  end

  describe "linking to an existing restricted record by id" do
    it "does not let a non-admin attach an existing restricted task via task_id" do
      restricted_task = create(:task, user: admin, restricted: true)

      post notices_path, params: { notice: attributes_for(:notice), task_id: restricted_task.id }

      expect(Notice.last.tasks).not_to include(restricted_task)
    end

    it "does not let a non-admin attach an existing restricted notice via notice_id" do
      restricted_notice = create(:notice, user: admin, restricted: true)

      post tasks_path, params: {
        task: attributes_for(:task),
        notice_id: restricted_notice.id,
        assignee_ids: [ user.id ]
      }

      expect(Task.where(user: user)).to be_none
    end

    it "returns 404 when a non-admin sets a restricted notice as parent_id" do
      restricted_notice = create(:notice, user: admin, restricted: true)

      expect {
        post notices_path, params: { notice: attributes_for(:notice), parent_id: restricted_notice.id }
      }.not_to change(Notice, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when a non-admin sets a restricted task as parent_id" do
      restricted_task = create(:task, user: admin, restricted: true)

      expect {
        post tasks_path, params: {
          task: attributes_for(:task),
          parent_id: restricted_task.id,
          assignee_ids: [ user.id ]
        }
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
