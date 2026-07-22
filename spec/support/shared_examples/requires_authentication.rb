RSpec.shared_examples "requires_authentication" do
  it "redirects to the login page" do
    subject

    expect(response).to redirect_to(login_path)
  end
end
