class UsersController < ApplicationController
  include Authorizable

  before_action :set_user, only: %i[show edit update]
  # new/create は対象レコードが無く「誰が従業員を登録できるか」という別の問い。
  before_action :require_admin, only: %i[new create]
  before_action -> { authorize_edit!(@user) }, only: %i[edit update]

  def index
    @q = User.readable.ransack(params[:q], auth_object: :user_list)
    @pagy, @users = pagy(@q.result.order(:name))
  end

  def show
    # Interaction は公開範囲を持たず demo 境界だけなので、readable な親から辿る限り境界は保たれる。
    @interactions = @user.interactions.order(occurred_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(create_user_params)

    if @user.save
      redirect_to @user, notice: "従業員を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "従業員情報を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = User.readable.find(params[:id])
  end

  def user_params
    permitted = %i[name email_address]
    permitted << :password if params.require(:user)[:password].present?

    params.require(:user).permit(*permitted)
  end

  # 権限は新規登録時にのみ選択できる。登録後は変更できない。
  # create は require_admin で守られているが、tasks/notices の同名メソッドと
  # 形を揃えるため、ここでも admin かどうかを明示的に確認する。
  def create_user_params
    return user_params unless Current.user.admin?

    user_params.merge(params.require(:user).permit(:admin))
  end
end
