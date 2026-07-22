require "rails_helper"

RSpec.describe "Customers search", type: :request do
  let(:user) { create(:user, name: "田中") }
  let(:customer) { create(:customer, name: "鈴木太郎", phone: "090-1111-2222", email: "suzuki@example.com") }
  let(:other_customer) { create(:customer, name: "佐藤花子", phone: "080-3333-4444", email: "sato@example.com") }

  before do
    sign_in(user)
    customer
    other_customer
  end

  describe "GET /customers" do
    it "returns all records when no search params are given" do
      get customers_path

      expect(response.body).to include(customer.name, other_customer.name)
    end

    it "filters by name" do
      get customers_path, params: { q: { name_cont: "鈴木" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by phone" do
      get customers_path, params: { q: { phone_cont: "090" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by email" do
      get customers_path, params: { q: { email_cont: "suzuki" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by multiple conditions combined" do
      get customers_path, params: { q: { name_cont: "鈴木", phone_cont: "090" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end
  end
end
