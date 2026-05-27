require 'rails_helper'

RSpec.describe InteractionTask, type: :model do
  describe 'associations' do
    it 'belongs to interaction' do
      expect(described_class.reflect_on_association(:interaction).macro)
        .to eq(:belongs_to)
    end

    it 'belongs to task' do
      expect(described_class.reflect_on_association(:task).macro)
        .to eq(:belongs_to)
    end
  end
end
