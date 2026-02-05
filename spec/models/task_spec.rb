require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:task)).to be_valid
    end

    it 'has a valid task with parent' do
      parent = create(:task)
      expect(parent).to be_valid
      child = create(:task, parent: parent)
      expect(child.parent).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to created_by_user (User)' do
      association = described_class.reflect_on_association(:created_by_user)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("User")
    end

    it 'belongs to parent task (optional)' do
      association = described_class.reflect_on_association(:parent)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:foreign_key]).to eq("parent_task_id")
      expect(association.options[:optional]).to be(true)
    end

    it 'has many children tasks' do
      association = described_class.reflect_on_association(:children)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:foreign_key]).to eq("parent_task_id")
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

    describe 'admin_only' do
      it 'is valid when admin_only is true' do
        task = build(:task, admin_only: true)
        expect(task).to be_valid
      end

      it 'is valid when admin_only is false' do
        task = build(:task, admin_only: false)
        expect(task).to be_valid
      end

      it 'is invalid when admin_only is nil' do
        task = build(:task, admin_only: nil)
        expect(task).to be_invalid
      end
    end
  end
end
