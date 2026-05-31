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
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children interactions' do
      association = described_class.reflect_on_association(:children)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Interaction")
      expect(association.options[:foreign_key]).to eq("parent_id")
    end
  end

  describe 'enum' do
    it 'defines correct channel values' do
      expect(described_class.channels).to eq(
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

    describe 'channel' do
      it 'is required' do
        interaction = build(:interaction, channel: "")
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

    describe "images" do
      let(:user)        { create(:user) }
      let(:interaction) { create(:interaction, user: user) }

      it "has_many_attached :images" do
        expect(described_class.reflect_on_attachment(:images)).to be_present
      end

      it "is valid with a jpeg image" do
        interaction.images.attach(valid_image)

        expect(interaction).to be_valid
      end

      it "is invalid with a non-image file" do
        interaction.images.attach(invalid_file)

        expect(interaction).not_to be_valid
        expect(interaction.errors[:images]).to be_present
      end

      it "is invalid when image exceeds 10MB" do
        interaction.images.attach(oversized_file)

        expect(interaction).not_to be_valid
        expect(interaction.errors[:images]).to be_present
      end

      it "is destroyed when record is destroyed" do
        interaction.images.attach(valid_image)

        expect { interaction.destroy }.to change(ActiveStorage::Attachment, :count).by(-1)
      end
    end
  end
end
