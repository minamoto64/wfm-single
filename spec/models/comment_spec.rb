require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "associations" do
    it "belongs to user" do
      expect(described_class.reflect_on_association(:user).macro)
        .to eq(:belongs_to)
    end

    it "belongs to commentable (polymorphic)" do
      reflection = described_class.reflect_on_association(:commentable)

      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:polymorphic]).to be(true)
    end
  end

  describe "validations" do
    it "is valid with content" do
      comment = build(:comment, :on_interaction, content: "テスト")

      expect(comment).to be_valid
    end

    it "invalid without content" do
      comment = build(:comment, :on_interaction, content: "")

      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to be_present
    end

    it "is invalid with nil content" do
      comment = build(:comment, :on_interaction, content: nil)

      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to be_present
    end

    it "is valid with content of 200 characters" do
      comment = build(:comment, :on_interaction, content: "a" * 200)

      expect(comment).to be_valid
    end

    it "is invalid with content of 201 characters" do
      comment = build(:comment, :on_interaction, content: "a" * 201)

      expect(comment).not_to be_valid
      expect(comment.errors[:content]).to be_present
    end
  end

  describe "polymorphic" do
    let(:user) { create(:user) }

    it "allows Interaction to be commentable" do
      comment = create(:comment, :on_interaction, user: user)

      expect(comment.commentable).to be_a(Interaction)
    end

    it "allows Task to be commentable" do
      comment = create(:comment, :on_task, user: user)

      expect(comment.commentable).to be_a(Task)
    end

    it "allows Notice to be commentable" do
      comment = create(:comment, :on_notice, user: user)

      expect(comment.commentable).to be_a(Notice)
    end
  end
end
