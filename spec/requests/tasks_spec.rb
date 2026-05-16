require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let!(:task) { create(:task, user: user) }
  let(:restricted_task) { create(:task, user: admin, restricted: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /tasks" do
    context "when the user is logged in" do
      before do
        restricted_task
        sign_in(user)
      end

      it "responds with HTTP 200 OK" do
        get tasks_path

        expect(response).to have_http_status(:ok)
      end

      it "displays the tasks list" do
        get tasks_path

        expect(response.body).to include(task.title)
        expect(response.body).to include(task.user.name)
        expect(response.body).to include(I18n.l(task.due_at))
      end

      it "does not display restricted tasks when the user is not an admin" do
        get tasks_path

        expect(response.body).not_to include(restricted_task.title)
      end
    end

    context "when the user is an admin" do
      before do
        restricted_task
        sign_in(admin)
      end

      it "displays all tasks including restricted tasks" do
        get tasks_path

        expect(response.body).to include(task.title)
        expect(response.body).to include(restricted_task.title)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get tasks_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /tasks/:id" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get task_path(task)

        expect(response).to have_http_status(:ok)
      end

      it "displays the task information" do
        get task_path(task)

        expect(response.body).to include(task.title)
        expect(response.body).to include(task.user.name)
        expect(response.body).to include(I18n.l(task.due_at))
        expect(response.body).to include(task.description)
      end

      it "cannot access a restricted task" do
        get task_path(restricted_task)

        expect(response).to redirect_to tasks_path
      end
    end

    context "when the user is an admin" do
      before { sign_in(admin) }

      it "can access a restricted task" do
        get task_path(restricted_task)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get task_path(task)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /tasks/new" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get new_task_path

        expect(response).to have_http_status(:ok)
      end

      it "does not display restricted check box" do
        get new_task_path

        expect(response.body).not_to include("管理者のみ")
      end
    end

    context "when the user is admin" do
      before { sign_in(admin) }

      it "displays restricted check box" do
        get new_task_path

        expect(response.body).to include("管理者のみ")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get new_task_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /tasks" do
    context "when the user is logged in" do
      before { sign_in(user) }

      let(:valid_params) do
        {
          task: {
            title: "テストタスク",
            description: "テストタスクの詳細",
            due_at: 1.week.from_now
          }
        }
      end

      it "creates a Task with valid params" do
        expect {
          post tasks_path, params: valid_params
        }.to change(Task, :count).by(1)
      end

      it "redirects to the show page with valid params" do
        post tasks_path, params: valid_params

        expect(response).to redirect_to(task_path(Task.last))
      end

      it "records the user who created it" do
        post tasks_path, params: valid_params

        expect(Task.last.user).to eq(user)
      end

      it "creates a child task" do
        parent = create(:task, user: user)

        expect {
          post tasks_path, params: {
            task: {
              title: "子テストタスク",
              description: "子テストタスクの詳細",
              parent_id: parent.id
            }
          }
        }.to change(Task, :count).by(1)
      end

      it "associates the parent task correctly" do
        parent = create(:task, user: user)

        post tasks_path, params: {
          task: {
            title: "子テストタスク",
            description: "子テストタスクの詳細",
            parent_id: parent.id
          }
        }

        expect(Task.last.parent).to eq(parent)
      end

      it "does not create a Task with invalid params" do
        expect {
          post tasks_path, params: { task: { title: nil } }
        }.not_to change(Task, :count)
      end

      it "re-renders the new template with invalid params" do
        post tasks_path, params: { task: { title: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "ignores restricted parameter" do
        post tasks_path, params: {
          task: {
            title: "テストタスク",
            description: "テストタスクの詳細",
            restricted: true
          }
        }

        expect(Task.last.restricted).to be(false)
      end
    end

    context "when the user is admin" do
      before { sign_in(admin) }

      it "allows to set restricted" do
        post tasks_path, params: {
          task: {
            title: "テストタスク",
            description: "テストタスクの詳細",
            restricted: true
          }
        }

        expect(Task.last.restricted).to be(true)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post tasks_path, params: {}

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
