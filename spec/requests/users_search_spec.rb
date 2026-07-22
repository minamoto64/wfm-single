require "rails_helper"

RSpec.describe "Users search", type: :request do
  let(:user)       { create(:user, name: "田中", admin: true) }
  let(:other_user) { create(:user, name: "山田", admin: false) }

  before do
    other_user
    sign_in(user)
  end

  describe "GET /users" do
    it "returns all records when no search params are given" do
      get users_path

      expect(response.body).to include(user.name, other_user.name)
    end

    it "filters by name" do
      get users_path, params: { q: { name_cont: "田中" } }

      expect(response.body).to include(user.name)
      expect(response.body).not_to include(other_user.name)
    end

    it "filters by email_address" do
      get users_path, params: { q: { email_address_cont: user.email_address } }

      expect(response.body).to include(user.name)
      expect(response.body).not_to include(other_user.name)
    end

    it "filters by admin status" do
      get users_path, params: { q: { admin_eq: true } }

      expect(response.body).to include(user.name)
      expect(response.body).not_to include(other_user.name)
    end

    it "filters by multiple conditions combined" do
      get users_path, params: { q: { name_cont: "田中", email_address_cont: user.email_address } }

      expect(response.body).to include(user.name)
      expect(response.body).not_to include(other_user.name)
    end
  end
end
