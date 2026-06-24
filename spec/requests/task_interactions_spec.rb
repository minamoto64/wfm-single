require "rails_helper"

RSpec.describe "Task Interactions", type: :request do
  include TaskRequestHelpers

  let(:user) { create(:user) }
  let(:interaction) { create(:interaction) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(user) }

  describe "GET/tasks/new with interaction_id" do
    it "passes interaction_id to the form" do
      get new_task_path(interaction_id: interaction.id)

      expect(response.body).to include(interaction.id.to_s)
    end
  end

  describe "POST /tasks with interaction_id" do
    let(:valid_params) do
      {
        task: {
          title: "テストタスク",
          description: "テストタスクの詳細",
          restricted: false,
          due_at: 7.days.from_now
        },
        interaction_id: interaction.id
      }
    end

    it "links the task to the interaction" do
      post tasks_path, params: create_task_with_assignees(valid_params)

      expect(Task.last.interactions).to include(interaction)
    end

    it "redirects to the created task" do
      post tasks_path, params: create_task_with_assignees(valid_params)

      expect(response).to redirect_to(task_path(Task.last))
    end

    it "does not link when interaction_id is absent" do
      post tasks_path, params: create_task_with_assignees(valid_params).except(:interaction_id)

      expect(Task.last.interactions).to be_empty
    end

    it "does not link when task save fails" do
      invalid_params = valid_params.deep_merge(task: { title: "" })

      expect {
        post tasks_path, params: invalid_params
      }.not_to change(Task, :count)
    end
  end

  describe "GET /tasks/:id - related interactions display" do
    let(:task) { create(:task, user: user) }

    context "when the task has linked interactions" do
      before { task.interactions << interaction }

      it "displays the linked interaction" do
        get task_path(task)

        expect(response.body).to include(interaction.request_content)
      end
    end

    context "when the task has no linked interactions" do
      it "displays the empty message" do
        get task_path(task)

        expect(response.body).to include("まだ関連応対履歴は登録されていません")
      end
    end
  end
end
