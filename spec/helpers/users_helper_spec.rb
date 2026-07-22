require "rails_helper"

RSpec.describe UsersHelper, type: :helper do
  describe "#user_admin_label" do
    it "labels the user as an administrator when admin is true" do
      user = build(:user, admin: true)

      expect(helper.user_admin_label(user)).to eq("管理者")
    end

    it "labels the user as general when admin is false" do
      user = build(:user, admin: false)

      expect(helper.user_admin_label(user)).to eq("一般")
    end
  end
end
