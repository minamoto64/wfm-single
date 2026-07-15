require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:task)).to be_valid
    end

    it 'has a valid task with parent' do
      task = create(:task, :with_parent)

      expect(task).to be_valid
      expect(task.parent).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)

      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to parent task (optional)' do
      association = described_class.reflect_on_association(:parent)

      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children tasks' do
      association = described_class.reflect_on_association(:children)

      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:foreign_key]).to eq("parent_id")
    end

    it 'has many task_assignments' do
      association = described_class.reflect_on_association(:task_assignments)

      expect(association.macro).to eq(:has_many)
    end

    it 'has_many users through task_assignments' do
      association = described_class.reflect_on_association(:assigned_users)

      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:task_assignments)
      expect(association.options[:source]).to eq(:user)
    end

    it 'belongs to root task (optional)' do
      association = described_class.reflect_on_association(:root)

      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many thread_tasks' do
      association = described_class.reflect_on_association(:thread_tasks)

      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:foreign_key]).to eq(:root_id)
    end
  end

  describe 'root assignment' do
    it 'sets root to itself when there is no parent' do
      task = create(:task)

      expect(task.root).to eq(task)
    end

    it 'inherits the root from the parent' do
      parent = create(:task)
      child = create(:task, parent: parent)

      expect(child.root).to eq(parent)
    end

    it 'inherits the same root across multiple generations' do
      root = create(:task)
      child = create(:task, parent: root)
      grandchild = create(:task, parent: child)

      expect(grandchild.root).to eq(root)
    end
  end

  describe '#related_tasks' do
    it 'returns other tasks in the same thread ordered by created_at' do
      parent = create(:task)
      earlier_related_task = create(:task, parent: parent)
      later_related_task = create(:task, parent: parent)

      expect(parent.related_tasks).to eq([ earlier_related_task, later_related_task ])
      expect(earlier_related_task.related_tasks).to eq([ parent, later_related_task ])
      expect(later_related_task.related_tasks).to eq([ parent, earlier_related_task ])
    end

    it 'returns an empty array when there are no related tasks' do
      task = create(:task)

      expect(task.related_tasks).to eq([])
    end

    it 'does not include itself' do
      parent = create(:task)
      create(:task, parent: parent)

      expect(parent.related_tasks).not_to include(parent)
    end
  end

  describe 'validations' do
    describe 'title' do
      it 'is required' do
        task = build(:task, title: "")

        expect(task).to be_invalid
      end

      it 'accepts title up to 50 characters' do
        task = build(:task, title: 'あ' * 50)

        expect(task).to be_valid
      end

      it 'rejects title longer than 50 characters' do
        task = build(:task, title: 'あ' * 51)

        expect(task).to be_invalid
      end
    end

    describe 'description' do
      it 'is required' do
        task = build(:task, description: "")

        expect(task).to be_invalid
      end

      it 'accepts description up to 2000 characters' do
        task = build(:task, description: 'あ' * 2000)

        expect(task).to be_valid
      end

      it 'rejects description longer than 2000 characters' do
        task = build(:task, description: 'あ' * 2001)

        expect(task).to be_invalid
      end
    end

    describe 'restricted' do
      it 'is valid when restricted is true' do
        task = build(:task, restricted: true)

        expect(task).to be_valid
      end

      it 'is valid when restricted is false' do
        task = build(:task, restricted: false)

        expect(task).to be_valid
      end

      it 'is invalid when restricted is nil' do
        task = build(:task, restricted: nil)

        expect(task).to be_invalid
      end
    end

    describe "images" do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }

      it "has_many_attached :images" do
        expect(described_class.reflect_on_attachment(:images)).to be_present
      end

      it "is valid with a jpeg image" do
        task.images.attach(valid_image)

        expect(task).to be_valid
      end

      it "is invalid with a non-image file" do
        task.images.attach(invalid_file)

        expect(task).not_to be_valid
        expect(task.errors[:images]).to be_present
      end

      it "is invalid when image exceeds 10MB" do
        task.images.attach(oversized_file)

        expect(task).not_to be_valid
        expect(task.errors[:images]).to be_present
      end

      it "is destroyed when record is destroyed" do
        task.images.attach(valid_image)

        expect { task.destroy }.to change(ActiveStorage::Attachment, :count).by(-1)
      end
    end
  end

  describe "ransackable_attributes" do
    it "permits restricted in addition to base attributes when auth_object is :admin" do
      expect(described_class.ransackable_attributes(:admin)).to include("title", "description", "due_at", "restricted")
    end

    it "does not permit restricted when auth_object is nil" do
      expect(described_class.ransackable_attributes(nil)).to include("title", "description", "due_at")
      expect(described_class.ransackable_attributes(nil)).not_to include("restricted")
    end

    it "falls back to the base list without restricted for unexpected auth_object values" do
      expect(described_class.ransackable_attributes(:something_else)).not_to include("restricted")
    end
  end

  describe "ransackable_associations" do
    it "permits task_assignments and user" do
      expect(described_class.ransackable_associations).to include("task_assignments", "user")
    end
  end

  describe "ransackable_scopes" do
    it "permits due_within" do
      expect(described_class.ransackable_scopes).to include("due_within")
    end
  end

  describe "due_within" do
    # Fixed date: Tuesday, June 11, 2024
    # end_of_week = Sunday, June 16, 2024
    # end_of_month = June 30, 2024
    around do |example|
      travel_to(Time.zone.local(2024, 6, 11, 12, 0, 0), &example)
    end

    let(:tasks) do
      {
        no_due: create(:task, due_at: nil),
        overdue: create(:task, due_at: Time.zone.local(2024, 6, 10, 9, 0, 0)),
        today: create(:task, due_at: Time.zone.local(2024, 6, 11, 15, 0, 0)),
        this_week: create(:task, due_at: Time.zone.local(2024, 6, 14, 12, 0, 0)),
        next_week: create(:task, due_at: Time.zone.local(2024, 6, 17, 12, 0, 0)),
        this_month: create(:task, due_at: Time.zone.local(2024, 6, 28, 12, 0, 0)),
        next_month: create(:task, due_at: Time.zone.local(2024, 7, 15, 12, 0, 0))
      }
    end

    it "returns only tasks with no due date when 'unset'" do
      result = described_class.due_within("unset")

      expect(result).to include(tasks[:no_due])
      expect(result).not_to include(tasks[:today])
    end

    it "returns only tasks past the start of today when 'overdue'" do
      result = described_class.due_within("overdue")

      expect(result).to include(tasks[:overdue])
      expect(result).not_to include(tasks[:today])
    end

    it "returns only tasks due within today when 'today'" do
      result = described_class.due_within("today")

      expect(result).to include(tasks[:today])
      expect(result).not_to include(tasks[:overdue], tasks[:this_week])
    end

    it "returns tasks due from today through end of this week when 'week'" do
      result = described_class.due_within("week")

      expect(result).to include(tasks[:today], tasks[:this_week])
      expect(result).not_to include(tasks[:overdue], tasks[:next_week])
    end

    it "returns tasks due from today through end of this month when 'month'" do
      result = described_class.due_within("month")

      expect(result).to include(tasks[:today], tasks[:next_week], tasks[:this_month])
      expect(result).not_to include(tasks[:overdue], tasks[:next_month])
    end

    it "returns all tasks when the period is an unknown value" do
      result = described_class.due_within("unknown")

      expect(result).to include(
        tasks[:no_due],
        tasks[:overdue],
        tasks[:today],
        tasks[:this_week],
        tasks[:next_week],
        tasks[:this_month],
        tasks[:next_month]
      )
    end
  end
end
