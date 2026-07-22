module AuthenticationHelpers
  def sign_in(user, password: user.password)
    post login_path, params: { email_address: user.email_address, password: password }
  end
end
