require "rails_helper"

RSpec.describe "Attachments", type: :request do
  let(:admin) { create(:user, admin: true) }
  let(:user)  { create(:user) }

  def attach_image(record)
    record.images.attach(valid_image)
    record.images.first
  end

  describe "GET /attachments/:id" do
    context "when signed in as a non-admin" do
      before { sign_in(user) }

      it "serves a task image" do
        image = attach_image(create(:task, user: user))

        get attachment_path(image)

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
      end

      it "serves a notice image" do
        image = attach_image(create(:notice, user: admin))

        get attachment_path(image)

        expect(response).to have_http_status(:ok)
      end

      it "serves an interaction image" do
        image = attach_image(create(:interaction, user: user))

        get attachment_path(image)

        expect(response).to have_http_status(:ok)
      end

      it "marks the response as privately cacheable" do
        image = attach_image(create(:task, user: user))

        get attachment_path(image)

        expect(response.headers["Cache-Control"]).to include("private", "max-age=3600")
      end

      it "does not serve an image of a restricted task" do
        image = attach_image(create(:task, user: admin, restricted: true))

        get attachment_path(image)

        expect(response).to have_http_status(:not_found)
      end

      it "does not serve an attachment on an unlisted record type" do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: Rails.root.join("spec/fixtures/files/test.jpg").open,
          filename: "test.jpg",
          content_type: "image/jpeg"
        )
        attachment = ActiveStorage::Attachment.create!(name: "images", record: create(:customer), blob: blob)

        get attachment_path(attachment)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when signed in as an admin" do
      before { sign_in(admin) }

      it "serves an image of a restricted task" do
        image = attach_image(create(:task, user: admin, restricted: true))

        get attachment_path(image)

        expect(response).to have_http_status(:ok)
        expect(response.body).to be_present
      end
    end

    context "when signed in as a demo user" do
      before { create(:user, demo: true, email_address: User::DEMO_LOGIN_EMAIL) }

      it "does not serve a production record's image" do
        image = attach_image(create(:task, user: user))

        post demo_login_path

        get attachment_path(image)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
