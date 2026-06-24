require "rails_helper"

RSpec.describe "Tasks search", type: :request do
  let(:admin)        { create(:user, name: "管理者", admin: true) }
  let(:regular_user) { create(:user, name: "一般ユーザー", admin: false) }

  let!(:public_task) { create(:task, title: "公開タスク", description: "誰でも閲覧可能なタスク", user: admin) }
  let!(:restricted_task) { create(:task, title: "限定タスク", description: "管理者専用コンテンツ", restricted: true, user: admin) }
  let!(:user_task)       { create(:task, title: "ユーザータスク", description: "一般ユーザーの作業", user: regular_user) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /tasks" do
    context "when signed in as admin" do
      before { sign_in(admin) }

      it "returns all records including restricted ones when no search params are given" do
        get tasks_path

        expect(response.body).to include(public_task.title, restricted_task.title, user_task.title)
      end

      it "filters by title keyword" do
        get tasks_path, params: { q: { title_cont: "公開" } }

        expect(response.body).to include(public_task.title)
        expect(response.body).not_to include(restricted_task.title, user_task.title)
      end

      it "filters by description keyword via title_or_description_cont" do
        get tasks_path, params: { q: { title_or_description_cont: "管理者専用" } }

        expect(response.body).to include(restricted_task.title)
        expect(response.body).not_to include(public_task.title, user_task.title)
      end

      it "filters by creator name" do
        get tasks_path, params: { q: { user_name_cont: "一般" } }

        expect(response.body).to include(user_task.title)
        expect(response.body).not_to include(public_task.title, restricted_task.title)
      end

      it "filters by restricted status" do
        get tasks_path, params: { q: { restricted_eq: true } }

        expect(response.body).to include(restricted_task.title)
        expect(response.body).not_to include(public_task.title, user_task.title)
      end

      it "filters by multiple conditions combined" do
        get tasks_path, params: { q: { user_name_cont: "管理者", restricted_eq: true } }

        expect(response.body).to include(restricted_task.title)
        expect(response.body).not_to include(public_task.title, user_task.title)
      end

      it "filters by assignee name" do
        assignee = create(:user, name: "担当者A")
        create(:task_assignment, task: public_task, user: assignee)

        get tasks_path, params: { q: { task_assignments_user_name_cont: "担当者A" } }

        expect(response.body).to include(public_task.title)
        expect(response.body).not_to include(user_task.title)
      end

      it "filters by assignee status" do
        assignee = create(:user, name: "担当者A")
        create(:task_assignment, task: user_task, user: assignee, status: :in_progress)

        get tasks_path, params: { q: { task_assignments_status_eq: "in_progress" } }

        expect(response.body).to include(user_task.title)
        expect(response.body).not_to include(public_task.title)
      end
    end

    context "when signed in as regular user" do
      before { sign_in(regular_user) }

      it "returns only non-restricted tasks when no search params are given" do
        get tasks_path

        expect(response.body).to include(public_task.title, user_task.title)
        expect(response.body).not_to include(restricted_task.title)
      end

      it "filters by title keyword among visible tasks only" do
        get tasks_path, params: { q: { title_cont: "公開" } }

        expect(response.body).to include(public_task.title)
        expect(response.body).not_to include(user_task.title, restricted_task.title)
      end

      it "filters by creator name among visible tasks only" do
        get tasks_path, params: { q: { user_name_cont: "一般" } }

        expect(response.body).to include(user_task.title)
        expect(response.body).not_to include(public_task.title)
      end

      it "cannot see restricted tasks even when passing restricted_eq: true" do
        get tasks_path, params: { q: { restricted_eq: true } }

        expect(response.body).not_to include(restricted_task.title)
      end
    end
  end
end
