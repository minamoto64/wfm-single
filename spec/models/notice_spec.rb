require 'rails_helper'

RSpec.describe Notice, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:notice)).to be_valid
    end

    it 'has a valid notice with parent' do
      notice = create(:notice, :with_parent)
      expect(notice).to be_valid
      expect(notice.parent).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to parent notice (optional)' do
      association = described_class.reflect_on_association(:parent)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children notices' do
      association = described_class.reflect_on_association(:children)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:foreign_key]).to eq("parent_id")
    end

    it 'belongs to root notice (optional)' do
      association = described_class.reflect_on_association(:root)

      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many rooted_notices' do
      association = described_class.reflect_on_association(:rooted_notices)

      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Notice")
      expect(association.options[:foreign_key]).to eq(:root_id)
    end
  end

  describe '#related_notices' do
    it 'returns other notices in the same thread ordered by created_at' do
      parent = create(:notice)
      earlier_related_notice = create(:notice, parent: parent)
      later_related_notice = create(:notice, parent: parent)

      expect(parent.related_notices).to eq([ earlier_related_notice, later_related_notice ])
      expect(earlier_related_notice.related_notices).to eq([ parent, later_related_notice ])
      expect(later_related_notice.related_notices).to eq([ parent, earlier_related_notice ])
    end

    it 'returns an empty array when there are no related notices' do
      notice = create(:notice)

      expect(notice.related_notices).to eq([])
    end

    it 'does not include itself' do
      parent = create(:notice)
      create(:notice, parent: parent)

      expect(parent.related_notices).not_to include(parent)
    end
  end

  describe "root assignment" do
    let(:user) { create(:user) }

    it "sets root_id for a child notice" do
      parent = create(:notice, user: user)
      child  = create(:notice, user: user, parent: parent)

      expect(child.root_id).to eq(parent.id)
    end

    it "sets itself as root when it has no parent" do
      notice = create(:notice, user: user)

      expect(notice.root).to eq(notice)
    end

    it "inherits root from parent" do
      parent = create(:notice, user: user)
      child  = create(:notice, user: user, parent: parent)

      expect(child.root).to eq(parent)
    end

    it "inherits root from the top-level notice" do
      parent = create(:notice, user: user)
      child = create(:notice, user: user, parent: parent)
      grandchild = create(:notice, user: user, parent: child)

      expect(grandchild.root).to eq(parent)
    end
  end

  describe 'enum' do
    it 'defines correct level values' do
      expect(described_class.levels.keys).to match_array(
        %w[important normal]
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

    describe 'level' do
      it 'is required' do
        notice = build(:notice, level: "")
        expect(notice).to be_invalid
      end
    end

    describe 'restricted' do
      it 'is valid when restricted is true' do
        notice = build(:notice, restricted: true)
        expect(notice).to be_valid
      end

      it 'is valid when restricted is false' do
        notice = build(:notice, restricted: false)
        expect(notice).to be_valid
      end

      it 'is invalid when restricted is nil' do
        notice = build(:notice, restricted: nil)
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

  describe "images" do
    let(:user)   { create(:user) }
    let(:notice) { create(:notice, user: user) }

    it "has_many_attached :images" do
      expect(described_class.reflect_on_attachment(:images)).to be_present
    end

    it "is valid with a jpeg image" do
      notice.images.attach(valid_image)

      expect(notice).to be_valid
    end

    it "is invalid with a non-image file" do
      notice.images.attach(invalid_file)

      expect(notice).not_to be_valid
      expect(notice.errors[:images]).to be_present
    end

    it "is invalid when image exceeds 10MB" do
      notice.images.attach(oversized_file)

      expect(notice).not_to be_valid
      expect(notice.errors[:images]).to be_present
    end

    it "is destroyed when record is destroyed" do
      notice.images.attach(valid_image)

      expect { notice.destroy }.to change(ActiveStorage::Attachment, :count).by(-1)
    end
  end

  describe "ransackable_attributes" do
    it "permits restricted in addition to base attributes when auth_object is :admin" do
      expect(described_class.ransackable_attributes(:admin)).to match_array(%w[title content level start_at end_at restricted])
    end

    it "does not permit restricted when auth_object is nil" do
      expect(described_class.ransackable_attributes(nil)).to match_array(%w[title content level start_at end_at])
    end

    it "falls back to the base list without restricted for unexpected auth_object values" do
      expect(described_class.ransackable_attributes(:something_else)).to match_array(%w[title content level start_at end_at])
    end
  end

  describe "ransackable_associations" do
    it "permits user" do
      expect(described_class.ransackable_associations).to include("user")
    end
  end

  describe "ransackable_scopes" do
    it "permits status" do
      expect(described_class.ransackable_scopes).to include("status")
    end
  end

  describe "status" do
    # Fixed date: Wednesday, June 11, 2025 12:00
    around do |example|
      travel_to(Time.zone.local(2025, 6, 11, 12, 0, 0), &example)
    end

    let(:notices) do
      {
        active:         create(:notice, start_at: 1.hour.ago,   end_at: 1.week.from_now),
        upcoming:        create(:notice, start_at: 1.hour.from_now, end_at: 2.hours.from_now),
        expired:        create(:notice, start_at: 2.weeks.ago,  end_at: 1.hour.ago),
        ends_now_edge:  create(:notice, start_at: 1.day.ago,    end_at: Time.current)
      }
    end

    it "returns only notices where start_at is past and end_at is future when 'active'" do
      result = described_class.status("active")

      expect(result).to include(notices[:active], notices[:ends_now_edge])
      expect(result).not_to include(notices[:upcoming], notices[:expired])
    end

    it "returns only notices where end_at is past when 'expired'" do
      result = described_class.status("expired")

      expect(result).to include(notices[:expired])
      expect(result).not_to include(notices[:active], notices[:upcoming])
    end

    it "returns all notices when the value is an unknown string" do
      result = described_class.status("unknown")

      expect(result).to include(
        notices[:active],
        notices[:upcoming],
        notices[:expired],
        notices[:ends_now_edge]
      )
    end
  end
end
