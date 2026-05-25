require 'rails_helper'

RSpec.describe InteractionNotice, type: :model do
  describe 'associations' do
    it 'belongs to interaction' do
      expect(described_class.reflect_on_association(:interaction).macro)
        .to eq(:belongs_to)
    end

    it 'belongs to notice' do
      expect(described_class.reflect_on_association(:notice).macro)
        .to eq(:belongs_to)
    end
  end
end
