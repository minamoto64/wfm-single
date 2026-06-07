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

  describe "#tab_link_to" do
    let(:tab) { { path: "/interactions", label: "応対履歴", name: "interactions" } }

    context "when the tab matches the current controller (active)" do
      subject(:rendered) { helper.tab_link_to(tab) }

      before { allow(helper).to receive(:controller_name).and_return("interactions") }

      it "applies active border class" do
        expect(rendered).to include("border-blue-500")
      end

      it "applies active text class" do
        expect(rendered).to include("text-blue-600")
      end

      it "does not apply inactive border class" do
        expect(rendered).not_to include("border-transparent")
      end
    end

    context "when the tab does not match the current controller (inactive)" do
      subject(:rendered) { helper.tab_link_to(tab) }

      before { allow(helper).to receive(:controller_name).and_return("tasks") }

      it "applies inactive border class" do
        expect(rendered).to include("border-transparent")
      end

      it "does not apply active border class" do
        expect(rendered).not_to include("border-blue-500")
      end
    end
  end
end
