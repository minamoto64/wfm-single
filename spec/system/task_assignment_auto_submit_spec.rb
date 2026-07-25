require "rails_helper"

RSpec.describe "Task assignment auto-submit", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let!(:task_assignment) { create(:task_assignment, task: task, user: user, status: "todo") }

  def sign_in(user)
    visit login_path

    fill_in "email_address", with: user.email_address
    fill_in "password", with: user.password
    click_button "ログイン"

    expect(page).to have_current_path(interactions_path)
  end

  before do
    sign_in(user)
    visit task_path(task)
  end

  describe "progress status select", :js do
    it "submits the update as soon as the status is changed, without a submit button" do
      select "進行中", from: "task_assignment_status"

      expect(page).to have_current_path(task_path(task))
      expect(page).to have_content("進捗状況を更新しました")
      expect(task_assignment.reload.status).to eq("in_progress")
    end
  end
end
