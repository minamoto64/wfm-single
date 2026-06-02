class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :require_admin, only: %i[new create edit update]

  def index
    @users = User.order(:name)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "従業員を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "従業員情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

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
