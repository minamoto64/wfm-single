require "rails_helper"

RSpec.describe "Demo data isolation", type: :request do
  let(:production_user) { create(:user) }
  let!(:production_customer) { create(:customer, name: "本番顧客サンプル") }
  let!(:demo_customer)        { create(:customer, name: "デモ顧客サンプル", demo: true) }

  before { create(:user, demo: true, email_address: User::DEMO_LOGIN_EMAIL) }

  # 通常ログイン(/login)は Current.demo? が false の状態で認証クエリが走るため、
  # demo: true のユーザーは通常ログインでは認証できない（意図した挙動）。
  # デモユーザーへのログインは専用の /login/demo からのみ行う。
  def sign_in_demo_user
    post demo_login_path
  end

  describe "customers index" do
    it "never shows demo data to a production user" do
      sign_in(production_user)

      get customers_path

      expect(response.body).to include("本番顧客サンプル")
      expect(response.body).not_to include("デモ顧客サンプル")
    end

    it "never shows production data to a demo user" do
      sign_in_demo_user

      get customers_path

      expect(response.body).to include("デモ顧客サンプル")
      expect(response.body).not_to include("本番顧客サンプル")
    end
  end

  describe "direct record access across the demo boundary" do
    it "blocks a production user from loading a demo record by id" do
      sign_in(production_user)

      get customer_path(demo_customer)

      expect(response).to have_http_status(:not_found)
    end

    it "blocks a demo user from loading a production record by id" do
      sign_in_demo_user

      get customer_path(production_customer)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "record creation" do
    it "tags records created by the demo user as demo data automatically" do
      Current.demo = true

      customer = Customer.create!(name: "自動判定テスト")

      expect(customer.demo).to be(true)
    ensure
      Current.demo = false
    end
  end
end
