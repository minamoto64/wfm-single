require "rails_helper"

RSpec.describe "Task Assignments", type: :request do
  let(:task_creator)     { create(:user) }
  let(:first_assignee) { create(:user) }
  let(:second_assignee) { create(:user) }

  let(:valid_task_attributes) do
    {
      title:       "タスク割り当てテスト",
      description: "タスク割り当てテストの説明",
      restricted:  false
    }
  end

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(task_creator) }

  describe "POST /tasks with assignee_ids" do
    context "with assignees" do
      it "creates task_assignments with status todo for each assignee" do
        expect {
          post tasks_path, params: {
            task:         valid_task_attributes,
            assignee_ids: [ first_assignee.id, second_assignee.id ]
          }
        }.to change(TaskAssignment, :count).by(2)

        assignments = TaskAssignment.last(2)
        expect(assignments.map(&:status)).to all(eq("todo"))
        expect(assignments.map(&:user_id)).to contain_exactly(first_assignee.id, second_assignee.id)
      end

      it "redirects to the created task show page" do
        post tasks_path, params: {
          task:         valid_task_attributes,
          assignee_ids: [ first_assignee.id ]
        }
        expect(response).to redirect_to(task_path(Task.last))
      end
    end

    context "without assignees" do
      it "returns 422 and shows error when assignee_ids is empty" do
        post tasks_path, params: { task: valid_task_attributes, assignee_ids: [] }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("担当者を1人以上選択してください")
      end

      it "does not create a task when assignee_ids is empty" do
        expect {
          post tasks_path, params: { task: valid_task_attributes, assignee_ids: [] }
        }.not_to change(Task, :count)
      end
    end
  end

  describe "GET /tasks/:id" do
    let(:task) { create(:task, user: task_creator) }

    context "with assignees" do
      before do
        create(:task_assignment, task: task, user: first_assignee, status: :todo)
        create(:task_assignment, task: task, user: second_assignee, status: :todo)
      end

      it "displays assignee names on the show page" do
        get task_path(task)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(first_assignee.name)
        expect(response.body).to include(second_assignee.name)
      end
    end

    context "without assignees" do
      it "displays the empty state message" do
        get task_path(task)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("まだ誰にも割り当てられていません")
      end
    end
  end
end
