require "rails_helper"

RSpec.describe "Task Notices", type: :request do
  include TaskRequestHelpers

  let(:user) { create(:user) }
  let(:notice) { create(:notice) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(user) }

  describe "GET/tasks/new with notice_id" do
    it "passes notice_id to the form" do
      get new_task_path(notice_id: notice.id)

      expect(response.body).to include(notice.id.to_s)
    end
  end

  describe "POST /tasks with notice_id" do
    let(:valid_params) do
      {
        task: {
          title: "テストタスク",
          description: "テストタスクの詳細",
          restricted: false,
          due_at: 7.days.from_now
        },
        notice_id: notice.id
      }
    end

    it "links the task to the notice" do
      post tasks_path, params: create_task_with_assignees(valid_params)

      expect(Task.last.notices).to include(notice)
    end

    it "redirects to the created task" do
      post tasks_path, params: create_task_with_assignees(valid_params)

      expect(response).to redirect_to(task_path(Task.last))
    end

    it "does not link when notice_id is absent" do
      post tasks_path, params: create_task_with_assignees(valid_params).except(:notice_id)

      expect(Task.last.notices).to be_empty
    end

    it "does not link when task save fails" do
      invalid_params = valid_params.deep_merge(task: { title: "" })

      expect {
        post tasks_path, params: invalid_params
      }.not_to change(Task, :count)
    end
  end

  describe "GET /tasks/:id - related notices display" do
    let(:task) { create(:task, user: user) }

    context "when the task has linked notices" do
      before { task.notices << notice }

      it "displays the linked notice" do
        get task_path(task)

        expect(response.body).to include(notice.content)
      end
    end

    context "when the task has no linked notices" do
      it "displays the empty message" do
        get task_path(task)

        expect(response.body).to include("まだ関連お知らせは登録されていません")
      end
    end
  end
end
