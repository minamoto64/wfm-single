require "rails_helper"

RSpec.describe "Tasks parent-child", type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, admin: true) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /tasks/:id - back link" do
    before { sign_in(user) }

    context "when the task has no parent" do
      let(:task) { create(:task, user: user) }

      it "links back to the index" do
        get task_path(task)

        expect(response.body).to include(tasks_path)
        expect(response.body).to include("一覧に戻る")
      end
    end

    context "when the task has a parent" do
      let(:parent) { create(:task, user: user) }
      let(:child) { create(:task, user: user, parent: parent) }

      it "links back to the index" do
        get task_path(child)

        expect(response.body).to include(tasks_path)
        expect(response.body).to include("一覧に戻る")
      end
    end
  end

  describe "/GET /tasks/:id - timeline" do
    before { sign_in(user) }

    context "when the task has no children" do
      let(:task) { create(:task, user: user) }

      it "renders a timeline including only itself" do
        get task_path(task)

        expect(response.body).to include(task.description.truncate(30))
      end
    end

    context "when viewing a parent task" do
      let(:parent) { create(:task, user: user) }
      let!(:child) { create(:task, user: user, parent: parent) }
      let!(:grandchild) { create(:task, user: user, parent: child) }

      it "displays all children in the timeline" do
        get task_path(parent)

        expect(response.body).to include(child.description.truncate(40))
        expect(response.body).to include(grandchild.description.truncate(40))
      end
    end

    context "when viewing a child task" do
      let(:parent) { create(:task, user: user) }
      let!(:child) { create(:task, user: user, parent: parent) }
      let!(:grandchild) { create(:task, user: user, parent: child) }

      it "displays the parent in the timeline" do
        get task_path(child)

        expect(response.body).to include(parent.description.truncate(40))
      end

      it "displays sibling tasks in the timeline" do
        get task_path(child)

        expect(response.body).to include(grandchild.description.truncate(40))
      end
    end

    context "when the task has descendants" do
      let(:parent) { create(:task, user: user) }
      let!(:child) { create(:task, user: user, parent: parent) }

      it "marks the currently viewed task with ★ 現在" do
        get task_path(parent)

        expect(response.body).to include("★ 現在")
      end

      it "links to other timeline items" do
        get task_path(parent)

        expect(response.body).to include(task_path(child))
      end

      it "does not link to the current task in the timeline" do
        get task_path(child)

        expect(response.body).not_to include(%(href="#{task_path(child)}"))
      end
    end

    context "when the task belongs to a hierarchy" do
      let!(:parent) { create(:task, user: user, created_at: 2.hours.ago) }
      let!(:child) do
        create(
          :task,
          user: user,
          parent: parent,
          description: "子タスクの詳細",
          created_at: 1.hour.ago
        )
      end

      let!(:grandchild) do
        create(
          :task,
          user: user,
          parent: child,
          description: "孫タスクの詳細",
          created_at: 30.minutes.ago
        )
      end

      it "displays items in chronological order" do
        get task_path(parent)

        expect(response.body).to match(/#{child.description}.*#{grandchild.description}/m)
      end
    end

    context "when the task can be followed up" do
      let(:task) { create(:task, user: user) }

      it "includes a link to create a child with parent_id" do
        get task_path(task)
        expect(response.body).to include(new_task_path(parent_id: task.id))
      end
    end
  end

  describe "GET /tasks/new with parent_id" do
    before { sign_in(user) }

    context "when creating a follow-up task from an existing task" do
      let(:parent) { create(:task, user: user) }

      it "responds with HTTP 200 OK" do
        get new_task_path(parent_id: parent.id)

        expect(response).to have_http_status(:ok)
      end

      it "includes the parent task id in the form" do
        get new_task_path(parent_id: parent.id)

        expect(response.body).to include(parent.id.to_s)
      end
    end

    context "when creating a follow-up task with a non-existent parent task" do
      it "responds with HTTP 200 OK and ignores the invalid parent_id" do
        get new_task_path(parent_id: 0)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /tasks with parent_id" do
    let!(:parent) { create(:task, user: user) }
    let(:child_params) do
      {
        task: {
          title: "子お知らせ",
          description: "子の詳細",
          level: "normal",
          start_at: 1.hour.ago,
          end_at: 1.week.from_now,
          parent_id: parent.id
        }
      }
    end

    context "when creating a follow-up task" do
      before { sign_in(user) }

      it "creates a task and associates it with the parent" do
        expect {
          post tasks_path, params: child_params
        }.to change(Task, :count).by(1)

        expect(Task.last.parent).to eq(parent)
      end

      it "redirects to the child task page" do
        post tasks_path, params: child_params

        expect(response).to redirect_to task_path(Task.last)
      end
    end

    context "when creating a root task" do
      before { sign_in(user) }

      it "creates a task without a parent" do
        post tasks_path, params: {
          task: {
            title: "ルートお知らせ",
            description: "詳細",
            level: "normal",
            start_at: 1.hour.ago,
            end_at: 1.week.from_now
          }
        }

        expect(Task.last.parent).to be_nil
      end
    end
  end
end
