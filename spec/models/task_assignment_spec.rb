require 'rails_helper'

RSpec.describe TaskAssignment, type: :model do
  it 'has a valid factory' do
    expect(build(:task_assignment)).to be_valid
  end

  describe 'associations' do
    it 'belongs to task' do
      association = described_class.reflect_on_association(:task)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'enum' do
    it 'defines correct status values' do
      expect(described_class.statuses.keys).to match_array(
        %w[todo in_progress done]
      )
    end
  end

  describe 'validations' do
    describe 'uniqueness of task_id scoped to user_id' do
      it 'must be unique for the same user' do
        assignment = create(:task_assignment)
        duplicate = build(:task_assignment, user: assignment.user, task: assignment.task)
        expect(duplicate).to be_invalid
      end
    end

    describe 'assignee of a restricted task' do
      let(:restricted_task) { create(:task, restricted: true, user: create(:user, admin: true)) }

      it 'is invalid when the assignee is not an admin' do
        assignment = build(:task_assignment, task: restricted_task, user: create(:user, admin: false))

        expect(assignment).to be_invalid
        expect(assignment.errors[:user]).to be_present
      end

      it 'is valid when the assignee is an admin' do
        assignment = build(:task_assignment, task: restricted_task, user: create(:user, admin: true))

        expect(assignment).to be_valid
      end

      it 'allows a non-admin assignee on a task that is not restricted' do
        assignment = build(:task_assignment, task: create(:task, restricted: false), user: create(:user, admin: false))

        expect(assignment).to be_valid
      end
    end
  end

  describe '.readable' do
    let(:restricted_task) { create(:task, restricted: true, user: create(:user, admin: true)) }
    let!(:assignment) { create(:task_assignment, task: restricted_task, user: create(:user, admin: true)) }

    it 'excludes assignments of restricted tasks for a non-admin' do
      Current.session = Session.new(user: create(:user, admin: false))

      expect(described_class.readable).not_to include(assignment)
    end

    it 'includes assignments of restricted tasks for an admin' do
      Current.session = Session.new(user: create(:user, admin: true))

      expect(described_class.readable).to include(assignment)
    end
  end
end
