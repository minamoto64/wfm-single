require 'rails_helper'

RSpec.describe NoticeTask, type: :model do
  describe "associations" do
    it 'belongs to notice' do
      expect(described_class.reflect_on_association(:notice).macro)
        .to eq(:belongs_to)
    end

    it 'belongs to task' do
      expect(described_class.reflect_on_association(:task).macro)
        .to eq(:belongs_to)
    end
  end
end
