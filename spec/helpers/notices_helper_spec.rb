require "rails_helper"

RSpec.describe NoticesHelper, type: :helper do
  describe "#notice_level_label" do
    it "marks the notice as requiring everyone's attention" do
      notice = build(:notice, level: "important")

      expect(helper.notice_level_label(notice)).to eq("高")
    end

    it "marks the notice as routine information" do
      notice = build(:notice, level: "normal")

      expect(helper.notice_level_label(notice)).to eq("低")
    end
  end
end
