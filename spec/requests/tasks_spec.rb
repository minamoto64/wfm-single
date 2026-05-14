require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let!(:task) { create(:task, user: user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /tasks" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get tasks_path

        expect(response).to have_http_status(:ok)
      end

      it "displays the tasks list" do
        get tasks_path

        expect(response.body).to include(task.title)
        expect(response.body).to include(task.user.name)
        expect(response.body).to include(I18n.l(task.due_at))
      end

      it "does not display restricted tasks when the user is not an admin" do
        restricted_task = create(:task, user: admin, restricted: true)

        get tasks_path

        expect(response.body).not_to include(restricted_task.title)
      end
    end

    context "when the user is an admin" do
      before { sign_in(admin) }

      it "displays all tasks including restricted tasks" do
        restricted_task = create(:task, user: admin, restricted: true)

        get tasks_path

        expect(response.body).to include(task.title)
        expect(response.body).to include(restricted_task.title)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get tasks_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
