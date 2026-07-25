require "rails_helper"

RSpec.describe "Clickable row navigation", type: :system do
  let(:user) { create(:user) }
  let!(:interaction) { create(:interaction, user: user) }

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

  describe "interaction row", :js do
    it "navigates to the interaction detail page when clicking a non-link part of the row" do
      row = find("[data-interaction-id='#{interaction.id}']")

      row.find("td", text: "電話", exact_text: false).click

      expect(page).to have_current_path(interaction_path(interaction))
      expect(page).to have_content("応対履歴詳細")
    end

    it "does not navigate via the row click handler when clicking the customer link" do
      row = find("[data-interaction-id='#{interaction.id}']")

      row.click_link(interaction.customer.name)

      expect(page).to have_current_path(customer_path(interaction.customer))
    end
  end
end
