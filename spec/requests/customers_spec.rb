require 'rails_helper'

RSpec.describe "Customers", type: :request do
  let(:user) { create(:user) }

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

      it "shows the (limit+1)th customer only on page 2" do
        limit = Pagy::DEFAULT[:items]
        (1..limit).each { |i| create(:customer, name: format("aaa_page_test_%02d", i), email: "aaa_page_test_#{i}@example.com") }
        target_customer = create(:customer, name: "zzz_page_test_target", email: "zzz_page_test_target@example.com")

        get customers_path
        expect(response.body).not_to include(target_customer.name)

        get customers_path, params: { page: 2 }
        expect(response.body).to include(target_customer.name)
      end
    end

    context "when the user is not logged in" do
      subject { get customers_path }

      it_behaves_like "requires_authentication"
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
      subject { get new_customer_path }

      it_behaves_like "requires_authentication"
    end
  end

  describe "POST /customers" do
    context "when the user is logged in" do
      before { sign_in(user) }

      let(:valid_params) { { customer: attributes_for(:customer) } }

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
      subject { post customers_path, params: {} }

      it_behaves_like "requires_authentication"
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
      subject { get customer_path(customer) }

      it_behaves_like "requires_authentication"
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
      subject { get edit_customer_path(customer) }

      it_behaves_like "requires_authentication"
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
      subject { patch customer_path(customer), params: {} }

      it_behaves_like "requires_authentication"
    end
  end
end
