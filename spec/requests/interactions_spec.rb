require 'rails_helper'

RSpec.describe "Interactions", type: :request do
  include InteractionsHelper

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

  describe "GET /interactions/:id" do
    let(:interaction) { create(:interaction, user: user) }

    context "when the user is logged in" do
      before { sign_in(user) }

      it "returns 200" do
        get interaction_path(interaction)
        expect(response).to have_http_status(:ok)
      end

      it "displays the customer and user information" do
        get interaction_path(interaction)
        expect(response.body).to include(interaction.customer.name)
        expect(response.body).to include(interaction.user.name)
      end

      it "displays the interaction content" do
        get interaction_path(interaction)
        expect(response.body).to include(I18n.l(interaction.occurred_at))
        expect(response.body).to include(interaction.request_content)
        expect(response.body).to include(interaction.response_result)
      end

      it "displays the interaction channel" do
        get interaction_path(interaction)
        expect(response.body).to include(interaction_channel_label(interaction))
      end

      it "displays the completion status" do
        get interaction_path(interaction)
        expect(response.body).to include("対応中")
      end

      it "displays completed status when interaction is completed" do
        completed_interaction = create(:interaction, user: user, completed: true)
        get interaction_path(completed_interaction)
        expect(response.body).to include("対応完了")
      end

      it "displays the edit button when the user is the owner" do
        get interaction_path(interaction)
        expect(response.body).to include(edit_interaction_path(interaction))
      end

      it "does not display the edit button when the user is not the owner" do
        other_interaction = create(:interaction)
        get interaction_path(other_interaction)
        expect(response.body).not_to include(edit_interaction_path(other_interaction))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get interaction_path(interaction)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
