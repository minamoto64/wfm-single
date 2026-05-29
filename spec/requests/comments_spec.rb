require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:other_user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
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

  describe "POST /comments" do
    it_behaves_like "allows posting comments", "interaction"
    it_behaves_like "allows posting comments", "task"
    it_behaves_like "allows posting comments", "notice"
  end
end
