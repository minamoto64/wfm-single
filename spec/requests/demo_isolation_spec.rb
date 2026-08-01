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

    context "when signed in as the demo user" do
      before { sign_in_demo_user }

      it "blocks a demo interaction from being attached to a production customer via customer_id" do
        post interactions_path, params: { interaction: attributes_for(:interaction), customer_id: production_customer.id }

        expect(Interaction.unscoped.where(customer_id: production_customer.id)).to be_none
      end

      it "blocks a demo interaction from being attached to a production interaction via parent_id" do
        production_parent_interaction = create(:interaction, customer: production_customer)

        post interactions_path, params: { interaction: attributes_for(:interaction), parent_id: production_parent_interaction.id }

        expect(Interaction.unscoped.where(parent_id: production_parent_interaction.id)).to be_none
      end

      it "blocks a demo notice from being attached to a production notice via parent_id" do
        production_parent_notice = create(:notice, user: production_user)

        post notices_path, params: { notice: attributes_for(:notice), parent_id: production_parent_notice.id }

        expect(Notice.unscoped.where(parent_id: production_parent_notice.id)).to be_none
      end

      it "blocks a demo task from being attached to a production task via parent_id" do
        production_parent_task = create(:task, user: production_user)

        post tasks_path, params: {
          task: attributes_for(:task),
          parent_id: production_parent_task.id,
          assignee_ids: [ User.find_by!(email_address: User::DEMO_LOGIN_EMAIL).id ]
        }

        expect(Task.unscoped.where(parent_id: production_parent_task.id)).to be_none
      end
    end
  end

  describe "record update" do
    let(:demo_user) { User.find_by!(email_address: User::DEMO_LOGIN_EMAIL) }

    before { sign_in_demo_user }

    def update_params(customer_id:, parent_id:)
      { interaction: attributes_for(:interaction), customer_id: customer_id, parent_id: parent_id }
    end

    it "does not let customer_id or parent_id be moved across the boundary via update" do
      demo_interaction = create(:interaction, customer: demo_customer, user: demo_user, demo: true)
      other_customer = create(:customer, demo: true)
      production_parent_interaction = create(:interaction, customer: production_customer)

      patch interaction_path(demo_interaction), params: update_params(customer_id: other_customer.id, parent_id: production_parent_interaction.id)

      demo_interaction.reload
      expect(demo_interaction.customer_id).to eq(demo_customer.id)
      expect(demo_interaction.parent_id).not_to eq(production_parent_interaction.id)
    end
  end
end
