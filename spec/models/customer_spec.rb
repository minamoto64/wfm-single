require 'rails_helper'

RSpec.describe Customer, type: :model do
  it 'has valid factory' do
    expect(build(:customer)).to be_valid
  end

  describe 'validations' do
    describe 'email normalization' do
      it 'is stripped and downcased' do
        customer = create(:customer, email: '  TEST@EXAMPLE.COM ')
        expect(customer.email).to eq('test@example.com')
      end
    end

    describe 'name' do
      it 'is required' do
        customer = build(:customer, name: '')
        expect(customer).to be_invalid
      end

      it 'is valid with names up to 50 characters' do
        customer = build(:customer, name: 'あ' * 50)
        expect(customer).to be_valid
      end

      it 'is invalid with names longer than 500 characters' do
        customer = build(:customer, name: 'あ' * 51)
        expect(customer).to be_invalid
      end

      it 'is valid when multiple customers have the same name' do
        customer_a = create(:customer, name: '伊藤綾香')
        customer_b = build(:customer, name: '伊藤綾香')
        expect(customer_b).to be_valid
      end
    end

    describe 'email' do
      it 'rejects invalid format' do
        customer = build(:customer, email: 'invalid-mail')
        expect(customer).to be_invalid
      end

      it 'is valid with a blank email' do
        customer = build(:customer, email: '')
        expect(customer).to be_valid
      end
    end

    describe 'phone' do
      it 'accepts valid format' do
        customer = build(:customer, phone: '03-1234-5678')
        expect(customer).to be_valid
      end

      it 'rejects invalid format' do
        customer = build(:customer, phone: '0312345678')
        expect(customer).to be_invalid
      end

      it 'rejects phone numbers not starting with 0' do
        customer = build(:customer, phone: '1-2345-6789')
        expect(customer).to be_invalid
      end

      it 'is valid with a blank phone' do
        customer = build(:customer, phone: '')
        expect(customer).to be_valid
      end
    end

    describe 'key_notes' do
      it 'is valid with key_notes up to 500 characters' do
        customer = build(:customer, key_notes: 'あ' * 500)
        expect(customer).to be_valid
      end

      it 'is invalid with key_notes longer than 500 characters' do
        customer = build(:customer, key_notes: 'あ' * 501)
        expect(customer).to be_invalid
      end
    end

    describe 'uuid' do
      it 'generates a uuid on creation' do
        expect(create(:customer).uuid).to be_present
      end

      it 'assigns different uuids when multiple customers have the same name' do
        customer_a = create(:customer, name: '伊藤綾香')
        customer_b = create(:customer, name: '伊藤綾香')
        expect(customer_a.uuid).not_to eq(customer_b.uuid)
      end
    end
  end

  describe 'ransackable_attributes' do
    context "when auth_object is :customer_list" do
      it "permits email in addition to name and phone" do
        expect(described_class.ransackable_attributes(:customer_list)).to include("name", "phone", "email")
      end
    end

    context "when auth_object is nil" do
      it "does not permit email" do
        expect(described_class.ransackable_attributes(nil)).to include("name", "phone")
        expect(described_class.ransackable_attributes(nil)).not_to include("email")
      end
    end

    context "when auth_object is some other unexpected value" do
      it "falls back to the restricted list" do
        expect(described_class.ransackable_attributes(:something_else)).not_to include("email")
      end
    end
  end
end
