require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  describe 'associations' do
    it 'destroys associated sessions when the user is deleted' do
      user = create(:user)
      user.sessions.create!
      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it 'has many created_tasks' do
      association = described_class.reflect_on_association(:created_tasks)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:class_name]).to eq("Task")
      expect(association.options[:foreign_key]).to eq("created_by_user_id")
    end

    it 'has many task_assignments' do
      association = described_class.reflect_on_association(:task_assignments)
      expect(association.macro).to eq(:has_many)
    end

    it 'has many assigned_tasks through task_assignments' do
      association = described_class.reflect_on_association(:assigned_tasks)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:task_assignments)
    end
  end

  describe 'validations' do
    describe 'email_address' do
      it 'is required' do
        user = build(:user, email_address: nil)
        expect(user).to be_invalid
      end

      it 'must be unique' do
        create(:user, email_address: "dup@example.com")
        user = build(:user, email_address: "dup@example.com")
        expect(user).to be_invalid
      end

      it 'rejects invalid format' do
        user = build(:user, email_address: 'invalid-mail')
        expect(user).to be_invalid
      end
    end

    describe 'email_address normalization' do
      it 'is stripped and downcased' do
        user = create(:user, email_address: '  TEST@EXAMPLE.COM ')
        expect(user.email_address).to eq('test@example.com')
      end
    end

    describe 'name' do
      it 'is required' do
        user = build(:user, name: nil)
        expect(user).to be_invalid
      end

      it 'accepts names up to 50 characters' do
        user = build(:user, name: 'あ' * 50)
        expect(user).to be_valid
      end

      it 'rejects names longer than 50 characters' do
        user = build(:user, name: 'あ' * 51)
        expect(user).to be_invalid
      end
    end

    describe 'password' do
      it 'must be at least 8 characters for new records' do
        user = build(:user, password: 'short')
        expect(user).to be_invalid
      end

      it 'accepts passwords with 8 or more characters' do
        user = build(:user, password: 'password')
        expect(user).to be_valid
      end

      it 'validates password length on update if password is changed' do
        user = create(:user, password: 'password123')
        user.password = 'short'
        expect(user).to be_invalid
      end

      it 'does not validate password length on update if password is not changed' do
        user = create(:user, password: 'password123')
        user.name = 'New name'
        expect(user).to be_valid
      end
    end

    describe 'admin flag' do
      it 'defaults to false' do
        expect(create(:user).admin).to be false
      end

      it 'can be set to true' do
        user = create(:user, admin: true)
        expect(user.admin).to be true
      end
    end
  end
end
