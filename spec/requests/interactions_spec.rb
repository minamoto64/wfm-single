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

  describe "GET /interactions/new" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "returns 200" do
        get new_interaction_path
        expect(response).to have_http_status(:ok)
      end

      it "inherits the same customer name if parent_id is present" do
        parent = create(:interaction, user: user)
        get new_interaction_path(parent_id: parent.id)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get interactions_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /interactions" do
    context "when the user is logged in" do
      before { sign_in(user) }

      let(:customer) { create(:customer) }
      let(:valid_params) do
        {
          interaction: {
            customer_id: customer.id,
            channel: "phone",
            occurred_at: Time.current,
            request_content: "新規要望",
            response_result: "対応しました！",
            completed: true
          }
        }
      end

      it "creates an Interaction with valid params" do
        expect {
          post interactions_path, params: valid_params
        }.to change(Interaction, :count).by(1)
      end

      it "redirects to the show page with valid params" do
        post interactions_path, params: valid_params
        expect(response).to redirect_to(interaction_path(Interaction.last))
      end

      it "records the user who created it" do
        post interactions_path, params: valid_params
        expect(Interaction.last.user).to eq(user)
      end

      it "does not create an Interaction with invalid params" do
        expect {
          post interactions_path, params: { interaction: { channel: nil } }
        }.not_to change(Interaction, :count)
      end

      it "re-renders the new template with invalid params" do
        post interactions_path, params: { interaction: { channel: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post interactions_path, params: {}
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

  describe "GET /interactions/:id/edit" do
    context "when the user is the creator" do
      before { sign_in(user) }

      it "returns 200" do
        interaction = create(:interaction, user: user)
        get edit_interaction_path(interaction)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not the creator" do
      it "redirects to the show page" do
        other_user = create(:user)
        interaction = create(:interaction, user: other_user)
        sign_in(user)
        get edit_interaction_path(interaction)
        expect(response).to redirect_to(interaction_path(interaction))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        interaction = create(:interaction, user: user)
        get edit_interaction_path(interaction)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /interactions/:id" do
    let(:interaction) { create(:interaction, user: user) }

    context "when the user is the creator with valid parameters" do
      before { sign_in(user) }

      it "updates the interaction" do
        patch interaction_path(interaction),
            params: { interaction: { request_content: "新規要望" } }
        expect(interaction.reload.request_content).to eq("新規要望")
      end

      it "redirects to the show page" do
        patch interaction_path(interaction),
            params: { interaction: { request_content: "新規要望" } }
        expect(response).to redirect_to(interaction_path(interaction))
      end
    end

    context "when the user is the creator with invalid parameters" do
      before { sign_in(user) }

      it "re-renders the edit template" do
        patch interaction_path(interaction),
              params: { interaction: { channel: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the user is not the creator" do
      it "does not update the interaction and redirects to the show page" do
        other_user = create(:user)
        sign_in(other_user)
        patch interaction_path(interaction),
            params: { interaction: { request_content: "無効な更新" } }
        expect(interaction.reload.request_content).not_to eq("無効な更新")
        expect(response).to redirect_to(interaction_path(interaction))
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        patch interaction_path(interaction), params: {}
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
