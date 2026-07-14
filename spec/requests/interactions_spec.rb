require 'rails_helper'

RSpec.describe "Interactions", type: :request do
  include InteractionsHelper

  let(:user) { create(:user) }
  let(:customer) { create(:customer, name: "鈴木太郎", phone: "090-1111-2222", email: "suzuki@example.com") }
  let(:other_customer) { create(:customer, name: "佐藤花子", phone: "080-3333-4444", email: "sato@example.com") }


  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
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

      it "uses full-page navigation for customer and user links inside turbo frame" do
        interaction = create(:interaction, user: user)

        get interactions_path

        expect(response.body).to include('data-turbo-frame="_top"')
        expect(response.body).to include(customer_path(interaction.customer))
        expect(response.body).to include(user_path(interaction.user))
      end

      it "displays completed status badge" do
        create(:interaction, user: user, completed: true)
        create(:interaction, user: user, completed: false)
        get interactions_path
        expect(response.body).to include("完了")
        expect(response.body).to include("対応中")
      end

      it "renders related interactions under the parent interaction row" do
        parent_interaction = create(:interaction, user: user)
        related_interaction = create(:interaction, user: user, parent: parent_interaction, request_content: "関連履歴の内容")

        get interactions_path

        expect(response.body).to include("関連")
        expect(response.body).to include(related_interaction.request_content)
      end

      it "renders sibling interactions as related, not just direct children" do
        parent_interaction = create(:interaction, user: user)
        first_sibling_interaction = create(:interaction, user: user, parent: parent_interaction, request_content: "関連履歴A")
        second_sibling_interaction = create(:interaction, user: user, parent: parent_interaction, request_content: "関連履歴B")

        get interactions_path

        expect(response.body).to include(first_sibling_interaction.request_content)
        expect(response.body).to include(second_sibling_interaction.request_content)
      end

      it "ignores unauthorized customer email filter and returns unfiltered results" do
        create(:interaction, customer: customer, user: user)
        create(:interaction, customer: other_customer, user: user)

        get interactions_path, params: { q: { customer_email_cont: customer.email } }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(customer.name, other_customer.name)
      end

      it "ignores unauthorized user email_address, admin filter and returns unfiltered results" do
        admin = create(:user, admin: true)
        create(:interaction, customer: customer, user: user)
        create(:interaction, customer: other_customer, user: admin)

        get interactions_path, params: {
          q: { email_address_cont: admin.email_address, admin_eq: true }
        }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(customer.name, other_customer.name)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get interactions_path
        expect(response).to redirect_to(login_path)
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
        expect(response).to redirect_to(login_path)
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
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post interactions_path, params: {}
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /interactions (with images)" do
    subject(:perform_request) do
      post interactions_path, params: {
        interaction: interaction_params
      }
    end

    let(:customer) { create(:customer) }
    let(:interaction_params) do
      attributes_for(
        :interaction,
        customer_id: customer.id
      ).merge(images: images)
    end

    before { sign_in(user) }

    context "with a valid image" do
      let(:images) { [ valid_image ] }

      it "creates an interaction with images" do
        expect { perform_request }
          .to change(Interaction, :count).by(1)

        expect(response).to redirect_to(interaction_path(Interaction.last))
        expect(Interaction.last.images).to be_attached
      end
    end

    context "with an invalid file" do
      let(:images) { [ invalid_file ] }

      it "does not create an interaction" do
        expect { perform_request }
          .not_to change(Interaction, :count)
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
        expect(response.body).to include("完了済")
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
        expect(response).to redirect_to(login_path)
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
        expect(response).to redirect_to(login_path)
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
        expect(response).to have_http_status(:unprocessable_content)
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
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH /interactions/:id (with images)" do
    let(:interaction) { create(:interaction, user: user) }

    before { sign_in(user) }

    it "updates an interaction with images" do
      patch interaction_path(interaction), params: {
        interaction: { images: [ valid_image ] }
      }

      expect(response).to redirect_to(interaction_path(interaction))
      expect(interaction.reload.images).to be_attached
    end
  end
end
