require "rails_helper"

RSpec.describe TaskAssignmentsHelper, type: :helper do
  describe "#task_status_label" do
    it "indicates the assignee has not touched the work yet" do
      assignment = build(:task_assignment, status: "todo")

      expect(helper.task_status_label(assignment)).to eq("未着手")
    end

    it "indicates the assignee is currently working on it" do
      assignment = build(:task_assignment, status: "in_progress")

      expect(helper.task_status_label(assignment)).to eq("進行中")
    end

    it "indicates the assignee has finished the work" do
      assignment = build(:task_assignment, status: "done")

      expect(helper.task_status_label(assignment)).to eq("完了")
    end
  end
end
