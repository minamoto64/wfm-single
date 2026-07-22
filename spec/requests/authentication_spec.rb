require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user) }

  describe "GET /login" do
    it "allows users to access login page" do
      get login_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /interactions" do
    subject { get interactions_path }

    it_behaves_like "requires_authentication"
  end

  describe "POST /login" do
    it "logs in successfully" do
      sign_in(user)

      expect(response).to redirect_to(interactions_path)
    end
  end

  describe "DELETE /logout" do
    it "logs out successfully" do
      sign_in(user)

      delete logout_path

      expect(response).to redirect_to(login_path)
    end
  end
end
