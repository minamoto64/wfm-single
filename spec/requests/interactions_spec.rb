require 'rails_helper'

RSpec.describe "Interactions", type: :request do
  let(:user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /interactions" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "returns 200" do
        get interactions_path
        expect(response).to have_http_status(:ok)
      end

      it "displays the interaction history list" do
        interaction = create(:interaction, user: user)
        get interactions_path
        expect(response.body).to include(interaction.customer.name)
        expect(response.body).to include(interaction.user.name)
        expect(response.body).to include(interaction.request_content)
      end

      it "displays completed status badge" do
        create(:interaction, user: user, completed: true)
        create(:interaction, user: user, completed: false)
        get interactions_path
        expect(response.body).to include("完了")
        expect(response.body).to include("対応中")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get interactions_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
