require "rails_helper"

RSpec.describe "Interactions search", type: :request do
  let(:customer) { create(:customer, name: "鈴木太郎", phone: "090-1111-2222") }
  let(:other_customer) { create(:customer, name: "佐藤花子", phone: "080-3333-4444") }
  let(:user) { create(:user, name: "田中") }
  let(:other_user) { create(:user, name: "山田") }

  before do
    sign_in(user)

    create(:interaction, customer: customer, user: user,
          channel: "phone", completed: false, occurred_at: "2026-06-01 10:00")
    create(:interaction, customer: other_customer, user: other_user,
          channel: "email", completed: true, occurred_at: "2026-06-10 10:00")
  end

  describe "GET /interactions" do
    it "returns all records when no search params are given" do
      get interactions_path

      expect(response.body).to include(customer.name, other_customer.name)
    end

    it "filters by customer name" do
      get interactions_path, params: { q: { customer_name_cont: "鈴木" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by customer phone" do
      get interactions_path, params: { q: { customer_phone_cont: "090" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by assignee name" do
      get interactions_path, params: { q: { user_name_cont: "田中" } }

      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end

    it "filters by channel" do
      get interactions_path, params: { q: { channel_eq: "email" } }

      expect(response.body).to include(other_customer.name)
      expect(response.body).not_to include(customer.name)
    end

    it "filters by completion status" do
      get interactions_path, params: { q: { completed_eq: "true" } }

      expect(response.body).to include(other_customer.name)
      expect(response.body).not_to include(customer.name)
    end

    it "filters by occurred_at range" do
      get interactions_path, params: { q: { occurred_at_gteq: "2026-06-05" } }
      expect(response.body).to include(other_customer.name)
      expect(response.body).not_to include(customer.name)
    end

    it "filters by multiple conditions combined" do
      get interactions_path, params: {
        q: { channel_eq: "phone", completed_eq: "false", occurred_at_lteq: "2026-06-05" }
      }
      expect(response.body).to include(customer.name)
      expect(response.body).not_to include(other_customer.name)
    end
  end
end
