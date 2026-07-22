require "rails_helper"

RSpec.describe "Header", type: :system do
  let(:user) { create(:user) }

  def sign_in(user)
    visit login_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(interactions_path)
  end

  describe "user menu dropdown", :js do
    before do
      sign_in(user)
    end

    it "is hidden by default" do
      expect(page).to have_css(
        "[data-dropdown-target='panel'].hidden",
        visible: :all
      )
    end

    it "opens when the user icon is clicked" do
      find("[data-dropdown-target='button']").click

      expect(page).not_to have_css("[data-dropdown-target='panel'].hidden")
    end

    it "closes when clicking outside the dropdown" do
      find("[data-dropdown-target='button']").click

      find("h1", text: "応対履歴一覧").click

      expect(page).to have_css(
        "[data-dropdown-target='panel'].hidden",
        visible: :all
      )
    end

    it "toggles aria-expanded on click" do
      button = find("[data-dropdown-target='button']")

      expect(button["aria-expanded"]).to eq("false")

      button.click

      expect(button["aria-expanded"]).to eq("true")
    end
  end
end
