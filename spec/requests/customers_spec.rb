require 'rails_helper'

RSpec.describe "Customers", type: :request do
  let(:user) { create(:user) }

  def sign_in(user)
    post login_path, params: { email_address: user.email_address, password: "password55" }
  end

  describe "GET /customers" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get customers_path

        expect(response).to have_http_status(:ok)
      end

      it "displays the customers list" do
        customer = create(:customer)

        get customers_path

        expect(response.body).to include(customer.name)
        expect(response.body).to include(customer.email)
        expect(response.body).to include(customer.phone)
        expect(response.body).to include(customer.key_notes)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get customers_path

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /customers/new" do
    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get new_customer_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get new_customer_path

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "POST /customers" do
    context "when the user is logged in" do
      before { sign_in(user) }

      let(:valid_params) do
        {
          customer: {
            name: "テスト顧客",
            email: "test@example.com",
            phone: "090-1234-5678",
            key_notes: "常連"
          }
        }
      end

      it "creates a Customer with valid params" do
        expect {
          post customers_path, params: valid_params
        }.to change(Customer, :count).by(1)
      end

      it "redirects to the show page with valid params" do
        post customers_path, params: valid_params

        expect(response).to redirect_to(customer_path(Customer.last))
      end

      it "does not create a Customer with invalid params" do
        expect {
          post customers_path, params: { customer: { name: nil } }
        }.not_to change(Customer, :count)
      end

      it "re-renders the new template with invalid params" do
        post customers_path, params: { customer: { name: nil } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        post customers_path, params: {}

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /customers/:id" do
    let(:customer) { create(:customer) }

    context "when the user is logged in" do
      before { sign_in(user) }

      it "responds with HTTP 200 OK" do
        get customer_path(customer)

        expect(response).to have_http_status(:ok)
      end

      it "displays the customer information" do
        get customer_path(customer)

        expect(response.body).to include(customer.name)
        expect(response.body).to include(customer.email)
        expect(response.body).to include(customer.phone)
        expect(response.body).to include(customer.key_notes)
      end

      it "displays related interactions for the customer" do
        interaction = create(:interaction, customer: customer, request_content: "関連する応対内容")

        get customer_path(customer)

        expect(response.body).to include("応対履歴")
        expect(response.body).to include(interaction.request_content)
      end

      it "displays a message when there are no related interactions" do
        get customer_path(customer)

        expect(response.body).to include("まだ応対履歴は登録されていません。")
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get customer_path(customer)

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "GET /customers/:id/edit" do
    let(:customer) { create(:customer) }

    context "when the user is logged in" do
      before { sign_in(user) }

      it "returns 200" do
        get edit_customer_path(customer)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        get edit_customer_path(customer)

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe "PATCH /customers/:id" do
    let(:customer) { create(:customer) }

    context "when the user is logged in" do
      before { sign_in(user) }

      it "updates the customer with valid parameters" do
        patch customer_path(customer),
          params: { customer: { name: "更新後の顧客名" } }

        expect(customer.reload.name).to eq("更新後の顧客名")
      end

      it "redirects to the show page with valid parameters" do
        patch customer_path(customer),
          params: { customer: { name: "更新後の顧客名" } }

        expect(response).to redirect_to(customer_path(customer))
      end

      it "re-renders the edit template with invalid parameters" do
        patch customer_path(customer),
          params: { customer: { name: nil } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when the user is not logged in" do
      it "redirects to the login page" do
        patch customer_path(customer), params: {}

        expect(response).to redirect_to(login_path)
      end
    end
  end
end
