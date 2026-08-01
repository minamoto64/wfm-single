class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new demo create ]
  rate_limit to: 10, within: 3.minutes, only: %i[ create demo ], with: -> { redirect_to login_path, alert: "Try again later." }

  def new
  end

  def demo
    demo_user = User.find_by!(email_address: User::DEMO_LOGIN_EMAIL, demo: true)
    start_new_session_for demo_user
    redirect_to interactions_path
  end

  def create
    # 認証前は Current.demo が未確定のため readable は使えない。素の検索で境界を掛けない。
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to interactions_path
    else
      redirect_to login_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to login_path, status: :see_other
  end
end
