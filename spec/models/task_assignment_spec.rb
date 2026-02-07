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
  end
end
