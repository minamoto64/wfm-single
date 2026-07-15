require "rails_helper"

RSpec.describe "Interaction Tasks", type: :request do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  let(:customer) { create(:customer) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(user) }

  describe "GET /interactions/:id - related tasks display" do
    let(:interaction) { create(:interaction, user: user, customer: customer) }

    context "when the interaction has linked tasks" do
      before { interaction.tasks << task }

      it "displays the linked task" do
        get interaction_path(interaction)

        expect(response.body).to include(task.title)
      end
    end

    context "when the interaction has no linked tasks" do
      it "displays the empty message" do
        get interaction_path(interaction)

        expect(response.body).to include("まだ関連するタスクは登録されていません")
      end
    end
  end
end
