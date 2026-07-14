require "rails_helper"

RSpec.describe InteractionsHelper, type: :helper do
  describe "#interaction_channel_label" do
    it "returns the translated channel label" do
      interaction = build(:interaction, channel: "phone")

      expect(helper.interaction_channel_label(interaction)).to eq("電話")
    end
  end

  describe "#interaction_status_label" do
    it "returns completed for completed interactions" do
      interaction = build(:interaction, completed: true)

      expect(helper.interaction_status_label(interaction)).to eq("完了済")
    end

    it "returns in progress for incomplete interactions" do
      interaction = build(:interaction, completed: false)

      expect(helper.interaction_status_label(interaction)).to eq("対応中")
    end
  end
end
