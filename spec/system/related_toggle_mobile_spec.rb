require "rails_helper"

RSpec.describe "Related toggle list (mobile)", type: :system do
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

  def mobile_card_group_for(task)
    all("[data-controller='related-toggle']").find { |el| el.text.include?(task.title) }
  end

  before do
    # The mobile card markup (app/views/tasks/_mobile_card.html.erb) and its
    # related_toggle_controller.js are only rendered below Tailwind's `md`
    # breakpoint (768px). The global system-spec hook forces a desktop-sized
    # window, so we deliberately narrow it back down here to exercise the
    # mobile-only code path.
    page.driver.browser.manage.window.resize_to(375, 812)

    sign_in(user)
    visit tasks_path
  end

  describe "mobile task card with related tasks", :js do
    it "shows a related toggle button for a task that has related tasks" do
      group = mobile_card_group_for(parent_task)

      expect(group).to have_button("関連")
    end

    it "does not show a related toggle button for a task without related tasks" do
      group = mobile_card_group_for(lone_task)

      expect(group).not_to have_button("関連")
    end

    it "reveals the related cards when the button is clicked" do
      group = mobile_card_group_for(parent_task)

      expect(group).to have_css("[data-related-toggle-target='list'].hidden", visible: :all)

      group.find(".related-toggle-button").click

      expect(group).to have_css("[data-related-toggle-target='list']", text: related_task.title, visible: :visible)
    end

    it "hides the related cards again when clicked a second time" do
      group = mobile_card_group_for(parent_task)
      button = group.find(".related-toggle-button")

      button.click
      expect(group).to have_css("[data-related-toggle-target='list']", text: related_task.title, visible: :visible)

      button.click
      expect(group).to have_css("[data-related-toggle-target='list'].hidden", text: related_task.title, visible: :all)
    end
  end
end
