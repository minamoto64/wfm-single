require "rails_helper"

RSpec.describe "Interactions parent-child", type: :request do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, admin: true) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /interactions/:id - back link" do
    before { sign_in(user) }

    context "when the interaction has no parent" do
      let(:interaction) { create(:interaction, user: user) }

      it "links back to the index" do
        get interaction_path(interaction)

        expect(response.body).to include(interactions_path)
        expect(response.body).to include("一覧に戻る")
      end
    end

    context "when the interaction has a parent" do
      let(:parent) { create(:interaction, user: user) }
      let(:child) { create(:interaction, user: user, parent: parent) }

      it "links back to the index" do
        get interaction_path(child)

        expect(response.body).to include(interactions_path)
        expect(response.body).to include("一覧に戻る")
      end
    end
  end

  describe "/GET /interactions/:id - timeline" do
    before { sign_in(user) }

    context "when the interaction has no children" do
      let(:interaction) { create(:interaction, user: user) }

      it "renders a timeline including only itself" do
        get interaction_path(interaction)

        expect(response.body).to include(interaction.response_result.truncate(30))
      end
    end

    context "when viewing a parent interaction" do
      let(:parent) { create(:interaction, user: user) }
      let!(:child) { create(:interaction, user: user, parent: parent) }
      let!(:grandchild) { create(:interaction, user: user, parent: child) }

      it "displays all children in the timeline" do
        get interaction_path(parent)

        expect(response.body).to include(child.response_result.truncate(40))
        expect(response.body).to include(grandchild.response_result.truncate(40))
      end
    end

    context "when viewing a child interaction" do
      let(:parent) { create(:interaction, user: user) }
      let!(:child) { create(:interaction, user: user, parent: parent) }
      let!(:grandchild) { create(:interaction, user: user, parent: child) }

      it "displays the parent in the timeline" do
        get interaction_path(child)

        expect(response.body).to include(parent.response_result.truncate(40))
      end

      it "displays sibling interactions in the timeline" do
        get interaction_path(child)

        expect(response.body).to include(grandchild.response_result.truncate(40))
      end
    end

    context "when the interaction has descendants" do
      let(:parent) { create(:interaction, user: user) }
      let!(:child) { create(:interaction, user: user, parent: parent) }

      it "marks the currently viewed interaction with ★ 現在" do
        get interaction_path(parent)

        expect(response.body).to include("★ 現在")
      end

      it "links to other timeline items" do
        get interaction_path(parent)

        expect(response.body).to include(interaction_path(child))
      end

      it "does not link to the current interaction in the timeline" do
        get interaction_path(child)

        expect(response.body).not_to include(%(href="#{interaction_path(child)}"))
      end
    end

    context "when the interaction belongs to a hierarchy" do
      let!(:parent) { create(:interaction, user: user, occurred_at: 2.hours.ago) }
      let!(:child) do
        create(
          :interaction,
          user: user,
          parent: parent,
          request_content: "子応対履歴",
          response_result: "子応対履歴の詳細",
          occurred_at: 1.hour.ago
        )
      end

      let!(:grandchild) do
        create(
          :interaction,
          user: user,
          parent: child,
          request_content: "孫応対履歴",
          response_result: "孫応対履歴の詳細",
          occurred_at: 30.minutes.ago
        )
      end

      it "displays items in chronological order" do
        get interaction_path(parent)

        expect(response.body).to match(/#{child.response_result}.*#{grandchild.response_result}/m)
      end
    end

    context "when the interaction can be followed up" do
      let(:interaction) { create(:interaction, user: user) }

      it "includes a link to create a child with parent_id" do
        get interaction_path(interaction)
        expect(response.body).to include(new_interaction_path(parent_id: interaction.id))
      end
    end
  end

  describe "GET /interactions/new with parent_id" do
    before { sign_in(user) }

    context "when creating a follow-up interaction from an existing interaction" do
      let(:parent) { create(:interaction, user: user) }

      it "responds with HTTP 200 OK" do
        get new_interaction_path(parent_id: parent.id)

        expect(response).to have_http_status(:ok)
      end

      it "includes the parent interaction id in the form" do
        get new_interaction_path(parent_id: parent.id)

        expect(response.body).to include(parent.id.to_s)
      end
    end

    context "when creating a follow-up interaction with a non-existent parent interaction" do
      it "responds with HTTP 200 OK and ignores the invalid parent_id" do
        get new_interaction_path(parent_id: 0)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /interactions with parent_id" do
    let!(:parent) { create(:interaction, user: user) }
    let(:child_params) do
      {
        interaction: {
          request_content: "子応対履歴",
          response_result: "子の応対履歴の詳細",
          completed: false,
          channel: "phone",
          occurred_at: 1.hour.ago,
          parent_id: parent.id
        }
      }
    end

    context "when creating a follow-up interaction" do
      before { sign_in(user) }

      it "creates a interaction and associates it with the parent" do
        expect {
          post interactions_path, params: child_params
        }.to change(Interaction, :count).by(1)

        expect(Interaction.last.parent).to eq(parent)
      end

      it "redirects to the child interaction page" do
        post interactions_path, params: child_params

        expect(response).to redirect_to interaction_path(Interaction.last)
      end
    end

    context "when creating a root interaction" do
      before { sign_in(user) }

      it "creates a interaction without a parent" do
        post interactions_path, params: {
          interaction: {
            request_content: "ルート応対履歴",
            response_result: "ルート応対履歴の詳細",
            completed: false,
            channel: "phone",
            occurred_at: 1.hour.ago
          }
        }

        expect(Interaction.last.parent).to be_nil
      end
    end
  end
end
