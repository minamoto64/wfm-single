require 'rails_helper'

RSpec.describe Notice, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:notice)).to be_valid
    end

    it 'has a valid notice with parent' do
      parent = create(:notice)
      expect(parent).to be_valid
      child = create(:notice, parent: parent)
      expect(child.parent).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:posted_by_user)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("User")
    end

    it 'belongs to parent notice (optional)' do
      association = described_class.reflect_on_association(:parent)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:foreign_key]).to eq("parent_notice_id")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children notices' do
      association = described_class.reflect_on_association(:children)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:foreign_key]).to eq("parent_notice_id")
    end
  end

  describe 'enum' do
    it 'defines correct notice_type values' do
      expect(described_class.notice_types.keys).to match_array(
        %w[important normal confidential]
      )
    end
  end

  describe 'validations' do
    describe 'title' do
      it 'is required' do
        notice = build(:notice, title: "")
        expect(notice).to be_invalid
      end

      it 'accepts title up to 50 characters' do
        notice = build(:notice, title: 'あ' * 50)
        expect(notice).to be_valid
      end

      it 'rejects title longer than 50 characters' do
        notice = build(:notice, title: 'あ' * 51)
        expect(notice).to be_invalid
      end
    end

    describe 'content' do
      it 'is required' do
        notice = build(:notice, content: "")
        expect(notice).to be_invalid
      end

      it 'accepts content up to 2000 characters' do
        notice = build(:notice, content: 'あ' * 2000)
        expect(notice).to be_valid
      end

      it 'rejects content longer than 2000 characters' do
        notice = build(:notice, content: 'あ' * 2001)
        expect(notice).to be_invalid
      end
    end

    describe 'notice_type' do
      it 'is required' do
        notice = build(:notice, notice_type: "")
        expect(notice).to be_invalid
      end
    end

    describe 'admin_only' do
      it 'is valid when admin_only is true' do
        notice = build(:notice, admin_only: true)
        expect(notice).to be_valid
      end

      it 'is valid when admin_only is false' do
        notice = build(:notice, admin_only: false)
        expect(notice).to be_valid
      end

      it 'is invalid when admin_only is nil' do
        notice = build(:notice, admin_only: nil)
        expect(notice).to be_invalid
      end
    end

    describe 'start_at' do
      it 'is required' do
        notice = build(:notice, start_at: nil)
        expect(notice).to be_invalid
      end
    end

    describe 'end_at' do
      it 'is required' do
        notice = build(:notice, end_at: nil)
        expect(notice).to be_invalid
      end
    end

    context 'when comparing chronological order' do
      let(:start_at) { Time.current }

      it 'is valid when end_at is after start_at' do
        notice = build(:notice, start_at: start_at, end_at: start_at + 1.day)
        expect(notice).to be_valid
      end

      it 'is invalid when end_at is not after start_at' do
        notice = build(:notice, start_at: start_at, end_at: start_at)
        expect(notice).to be_invalid
      end
    end
  end
end
