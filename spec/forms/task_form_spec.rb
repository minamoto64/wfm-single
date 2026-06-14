require "rails_helper"

RSpec.describe TaskForm do
  let(:user)     { create(:user) }
  let(:assignee) { create(:user) }

  let(:task) do
    user.tasks.build(
      title:       "タイトル",
      description: "説明",
      due_at:      1.week.from_now
    )
  end

  describe "#save" do
    context "with valid attributes and assignees" do
      subject(:form) { described_class.new(task: task, assignee_ids: [ assignee.id.to_s ]) }

      it "saves the task" do
        expect { form.save }.to change(Task, :count).by(1)
      end

      it "creates a task_assignment with status todo" do
        form.save
        assignment = task.task_assignments.last
        expect(assignment.user).to eq(assignee)
        expect(assignment.status).to eq("todo")
      end
    end

    context "with duplicated assignee_ids" do
      subject(:form) do
        described_class.new(
          task: task,
          assignee_ids: [ assignee.id.to_s, assignee.id.to_s ]
        )
      end

      it "creates only one task_assignment" do
        expect {
          form.save
        }.to change(TaskAssignment, :count).by(1)
      end
    end

    context "without assignee_ids on a new record" do
      subject(:form) { described_class.new(task: task, assignee_ids: []) }

      it "does not save the task" do
        expect { form.save }.not_to change(Task, :count)
      end

      it "adds a base error" do
        form.save
        expect(form.errors[:base]).to include("担当者を1人以上選択してください")
      end
    end

    context "with invalid task attributes" do
      subject(:form) { described_class.new(task: task, assignee_ids: [ assignee.id.to_s ]) }

      let(:task) { user.tasks.build(title: nil, description: "説明") }

      it "does not save the task" do
        expect { form.save }.not_to change(Task, :count)
      end

      it "exposes the task's validation errors" do
        form.save
        expect(form.errors[:base]).to be_present
      end
    end

    context "when updating an existing task without assignee_ids" do
      subject(:form) { described_class.new(task: persisted_task, assignee_ids: []) }

      let(:persisted_task) { create(:task, user: user, description: "元の説明") }

      it "does not require an assignee" do
        persisted_task.description = "更新後の説明"
        expect(form.valid?).to be(true)
      end

      it "raises when save is called on a persisted task" do
        expect { form.save }.to raise_error(/does not support existing records/)
      end
    end
  end
end
