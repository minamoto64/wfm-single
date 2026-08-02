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

  describe "POST /tasks with assignee_ids" do
    before { sign_in(task_creator) }

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

    before { sign_in(task_creator) }

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

  describe "PATCH /task_assignments/:id" do
    let(:assignment) do
      create(:task_assignment, task: create(:task, user: task_creator), user: first_assignee, status: :todo)
    end

    context "when the current user is the assignee" do
      before { sign_in(first_assignee) }

      it "updates the status" do
        patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } }

        expect(assignment.reload.status).to eq("done")
        expect(response).to redirect_to(task_path(assignment.task))
      end
    end

    context "when the current user is not the assignee" do
      before { sign_in(second_assignee) }

      it "does not update the status" do
        patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } }

        expect(assignment.reload.status).to eq("todo")
      end

      it "redirects to the task page with an alert" do
        patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } }

        expect(response).to redirect_to(task_path(assignment.task))
      end
    end

    context "when not signed in" do
      subject { patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } } }

      it_behaves_like "requires_authentication"
    end

    # 過去データ由来で非 admin が管理者限定タスクの assignment を持っている状況を再現する。
    # 割り当て後に restricted へ切り替えることでしか作れないため update_column で作る。
    context "when the assignment belongs to a restricted task" do
      # 割り当て後に restricted へ切り替えないと作れない状態のため update_column で作る。
      def assign_then_restrict(assignee)
        task = create(:task, user: task_creator, restricted: false)
        assignment = create(:task_assignment, task: task, user: assignee, status: :todo)
        task.update_column(:restricted, true)
        assignment
      end

      it "does not let a non-admin assignee update the status" do
        assignment = assign_then_restrict(first_assignee)
        sign_in(first_assignee)

        expect {
          patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } }
        }.not_to change { assignment.reload.status }

        expect(response).to have_http_status(:not_found)
      end

      it "lets an admin assignee update the status" do
        admin_assignee = create(:user, admin: true)
        assignment = assign_then_restrict(admin_assignee)

        sign_in(admin_assignee)
        patch task_assignment_path(assignment), params: { task_assignment: { status: "done" } }

        expect(assignment.reload.status).to eq("done")
      end
    end
  end

  describe "POST /tasks with a restricted task" do
    let(:admin) { create(:user, admin: true) }

    def restricted_task_attributes
      {
        title:       "管理者限定タスク",
        description: "管理者限定タスクの説明",
        restricted:  true
      }
    end

    before { sign_in(admin) }

    it "returns 422 and re-renders the form when a non-admin is selected" do
      post tasks_path, params: {
        task:         restricted_task_attributes,
        assignee_ids: [ create(:user, admin: false).id ]
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("管理者以外を担当者に指定できません")
    end

    it "does not create the task when a non-admin is selected" do
      expect {
        post tasks_path, params: {
          task:         restricted_task_attributes,
          assignee_ids: [ create(:user, admin: false).id ]
        }
      }.not_to change(Task, :count)

      expect(TaskAssignment.count).to eq(0)
    end

    it "creates the task when every assignee is an admin" do
      other_admin = create(:user, admin: true)

      expect {
        post tasks_path, params: {
          task:         restricted_task_attributes,
          assignee_ids: [ other_admin.id ]
        }
      }.to change(Task, :count).by(1)

      expect(response).to redirect_to(task_path(Task.last))
    end
  end
end
