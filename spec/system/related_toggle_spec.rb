require "rails_helper"

RSpec.describe "Related toggle list", type: :system do
  let(:user) { create(:user) }
  let(:parent_task) { create(:task, user: user) }
  let!(:related_task) { create(:task, :with_parent, user: user, parent: parent_task) }
  let!(:lone_task) { create(:task, user: user) }

  def sign_in(user)
    visit login_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(interactions_path)
  end

  before do
    sign_in(user)
    visit tasks_path
  end

  describe "task row with related tasks", :js do
    it "shows a related toggle button for a task that has related tasks" do
      row = find(".related-list-trigger[data-task-id='#{parent_task.id}']")

      expect(row).to have_button("関連")
    end

    it "does not show a related toggle button for a task without related tasks" do
      row = find(".related-list-trigger[data-task-id='#{lone_task.id}']")

      expect(row).not_to have_button("関連")
    end

    it "reveals the related rows when the button is clicked" do
      expect(page).to have_css(".related-list-row.hidden", visible: :all)

      find(".related-list-trigger[data-task-id='#{parent_task.id}'] .related-toggle-button").click

      expect(page).to have_css(".related-list-row", text: related_task.title, visible: :visible)
    end

    it "hides the related rows again when clicked a second time" do
      button = find(".related-list-trigger[data-task-id='#{parent_task.id}'] .related-toggle-button")

      button.click
      expect(page).to have_css(".related-list-row", text: related_task.title, visible: :visible)

      button.click
      expect(page).to have_css(".related-list-row.hidden", text: related_task.title, visible: :all)
    end
  end
end
