require "rails_helper"

RSpec.describe "Disclosure search panel", type: :system do
  let(:user) { create(:user) }

  def sign_in(user)
    visit login_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(interactions_path)
  end

  before do
    sign_in(user)
    visit interactions_path
  end

  describe "search panel", :js do
    it "is hidden by default" do
      expect(page).to have_css("[data-disclosure-target='panel'].hidden", visible: :all)
    end

    it "is revealed when the search header is clicked" do
      find("h2", text: "検索").click

      expect(page).to have_css("[data-disclosure-target='panel']", visible: :visible)
      expect(page).not_to have_css("[data-disclosure-target='panel'].hidden")
    end

    it "is hidden again when clicked a second time" do
      find("h2", text: "検索").click
      expect(page).not_to have_css("[data-disclosure-target='panel'].hidden")

      find("h2", text: "検索").click
      expect(page).to have_css("[data-disclosure-target='panel'].hidden", visible: :all)
    end
  end
end
