require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  before { sign_in(user) }

  shared_examples "allows posting comments" do |commentable_factory|
    let(:commentable) { create(commentable_factory, user: user) }

    it "creates a comment successfully" do
      expect {
          post comments_path, params: {
            commentable_type: commentable.class.name,
            commentable_id: commentable.id,
            comment: { content: "テストコメント" }
          }
        }.to change(Comment, :count).by (1)

      expect(response).to redirect_to commentable
    end

    it "does not create a comment when content is blank" do
      expect {
        post comments_path, params: {
          commentable_type: commentable.class.name,
          commentable_id: commentable.id,
          comment: { content: "" }
        }
      }.not_to change(Comment, :count)
    end
  end

  shared_examples "restricts posting comments" do |commentable_factory|
    let(:commentable) { create(commentable_factory, user: other_user, restricted: true) }

    it "does not allow a non-admin user to comment on a restricted record" do
      expect {
        post comments_path, params: {
          commentable_type: commentable.class.name,
          commentable_id: commentable.id,
          comment: { content: "テストコメント" }
        }
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "allows an admin user to comment on a restricted record" do
      sign_in(create(:user, admin: true))

      expect {
        post comments_path, params: {
          commentable_type: commentable.class.name,
          commentable_id: commentable.id,
          comment: { content: "テストコメント" }
        }
      }.to change(Comment, :count).by(1)

      expect(response).to redirect_to commentable
    end
  end

  describe "POST /comments" do
    it_behaves_like "allows posting comments", "interaction"
    it_behaves_like "allows posting comments", "task"
    it_behaves_like "allows posting comments", "notice"

    it_behaves_like "restricts posting comments", "task"
    it_behaves_like "restricts posting comments", "notice"

    context "with a commentable_type outside the whitelist" do
      it "returns 404 for a non-commentable model" do
        commentable_user = create(:user)

        post comments_path, params: {
          commentable_type: "User",
          commentable_id: commentable_user.id,
          comment: { content: "テストコメント" }
        }

        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for a nonexistent class name" do
        post comments_path, params: {
          commentable_type: "NonexistentModel",
          commentable_id: 1,
          comment: { content: "テストコメント" }
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
