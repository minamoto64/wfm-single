RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "allows users to access landing page" do
      get root_path

      expect(response).to have_http_status(:ok)
    end
  end
end
