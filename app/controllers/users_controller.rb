class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :require_admin, only: %i[new create edit update]

  def index
    @users = User.order(:name)
  end

  def new; end
  def create; end
  def show; end
  def edit; end
  def update; end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = %i[
      name
      email_address
      admin
    ]

    permitted << :password if params.require(:user)[:password].present?

    params.require(:user).permit(permitted)
  end
end
