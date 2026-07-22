require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#navigation_tabs" do
    subject(:tabs) { helper.navigation_tabs }

    it "returns 5 tabs" do
      expect(tabs.length).to eq(5)
    end

    it "returns tabs in the correct order" do
      expect(tabs.map { |t| t[:name] }).to eq(%w[interactions tasks notices customers users])
    end

    it "returns correct labels" do
      expect(tabs.map { |t| t[:label] }).to eq(%w[応対履歴 タスク お知らせ 顧客 従業員])
    end

    it "returns correct paths" do
      expect(tabs.map { |t| t[:path] }).to eq([
        interactions_path,
        tasks_path,
        notices_path,
        customers_path,
        users_path
      ])
    end
  end
end
