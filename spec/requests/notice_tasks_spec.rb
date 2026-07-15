require "rails_helper"

RSpec.describe "Notice Tasks", type: :request do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(user) }

  describe "GET /notices/new with task_id" do
    it "passes task_id to the form" do
      get new_notice_path(task_id: task.id)

      expect(response.body).to include(task.id.to_s)
    end
  end

  describe "POST /notices with task_id" do
    let(:valid_params) do
      {
        notice: {
          title: "テストお知らせ",
          content: "テストお知らせの詳細",
          level: "normal",
          start_at: 1.day.from_now,
          end_at: 7.days.from_now
        },
        task_id: task.id
      }
    end

    it "links the notice to the task" do
      post notices_path, params: valid_params

      expect(Notice.last.tasks).to include(task)
    end

    it "redirects to the created notice" do
      post notices_path, params: valid_params

      expect(response).to redirect_to(notice_path(Notice.last))
    end

    it "does not link when task_id is absent" do
      post notices_path, params: valid_params.except(:task_id)

      expect(Notice.last.tasks).to be_empty
    end

    it "does not link when notice save fails" do
      invalid_params = valid_params.deep_merge(notice: { title: "" })

      expect {
        post notices_path, params: invalid_params
      }.not_to change(Notice, :count)
    end
  end
end
