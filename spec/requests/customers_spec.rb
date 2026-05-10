require 'rails_helper'

RSpec.describe "Customers", type: :request do
  let(:user) { create(:user) }

  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password55" }
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
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
