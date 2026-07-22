require "rails_helper"

RSpec.describe "Notice Interactions", type: :request do
  let(:user) { create(:user) }
  let(:interaction) { create(:interaction) }

  before { sign_in(user) }

  describe "GET/notices/new with interaction_id" do
    it "passes interaction_id to the form" do
      get new_notice_path(interaction_id: interaction.id)

      expect(response.body).to include(interaction.id.to_s)
    end
  end

  describe "POST /notices with interaction_id" do
    let(:valid_params) do
      {
        notice: attributes_for(:notice),
        interaction_id: interaction.id
      }
    end

    it "links the notice to the interaction" do
      post notices_path, params: valid_params

      expect(Notice.last.interactions).to include(interaction)
    end

    it "redirects to the created notice" do
      post notices_path, params: valid_params

      expect(response).to redirect_to(notice_path(Notice.last))
    end

    it "does not link when interaction_id is absent" do
      post notices_path, params: valid_params.except(:interaction_id)

      expect(Notice.last.interactions).to be_empty
    end

    it "does not link when notice save fails" do
      invalid_params = valid_params.deep_merge(notice: { title: "" })

      expect {
        post notices_path, params: invalid_params
      }.not_to change(Notice, :count)
    end
  end

  describe "GET /notices/:id - related interactions display" do
    let(:notice) { create(:notice, user: user) }

    context "when the notice has linked interactions" do
      before { notice.interactions << interaction }

      it "displays the linked interaction" do
        get notice_path(notice)

        expect(response.body).to include(interaction.request_content)
      end
    end

    context "when the notice has no linked interactions" do
      it "displays the empty message" do
        get notice_path(notice)

        expect(response.body).to include("まだ関連応対履歴は登録されていません")
      end
    end
  end
end
