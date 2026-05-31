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
    it 'belongs to user)' do
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
      expect(association.options[:source]).to eq (:user)
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
end
