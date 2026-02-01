require 'rails_helper'

RSpec.describe Interaction, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:interaction)).to be_valid
    end

    it 'has a valid interaction with parent' do
      interaction = create(:interaction, :with_parent)
      expect(interaction).to be_valid
      expect(interaction.parent).to be_present
      expect(interaction.parent.customer).to eq(interaction.customer)
    end
  end

  describe 'associations' do
    it 'belongs to customer' do
      association = described_class.reflect_on_association(:customer)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to parent interaction (optional)' do
      association = described_class.reflect_on_association(:parent)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Interaction")
      expect(association.options[:foreign_key]).to eq("parent_interaction_id")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children interactions' do
      association = described_class.reflect_on_association(:children)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Interaction")
      expect(association.options[:foreign_key]).to eq("parent_interaction_id")
    end
  end

  describe 'enum' do
    it 'defines correct interaction_type values' do
      expect(described_class.interaction_types).to eq(
        "phone" => "phone",
        "email" => "email",
        "web" => "web",
        "sns" => "sns",
        "in_person" => "in_person"
      )
    end
  end

  describe 'validations' do
    describe 'occurred_at' do
      it 'is required' do
        interaction = build(:interaction, occurred_at: nil)
        expect(interaction).to be_invalid
      end
    end

    describe 'interaction_type' do
      it 'is required' do
        interaction = build(:interaction, interaction_type: "")
        expect(interaction).to be_invalid
      end
    end

    describe 'request_content' do
      it 'is required' do
        interaction = build(:interaction, request_content: "")
        expect(interaction).to be_invalid
      end
    end

    describe 'response_result' do
      it 'is required' do
        interaction = build(:interaction, response_result: "")
        expect(interaction).to be_invalid
      end
    end

    describe 'completed' do
      it 'is valid when completed is true' do
        interaction = build(:interaction, completed: true)
        expect(interaction).to be_valid
      end

      it 'is valid when completed is false' do
        interaction = build(:interaction, completed: false)
        expect(interaction).to be_valid
      end

      it 'is invalid when completed is nil' do
        interaction = build(:interaction, completed: nil)
        expect(interaction).to be_invalid
      end
    end
  end
end
