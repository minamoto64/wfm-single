class CustomersController < ApplicationController
  include Authorizable

  before_action :set_customer, only: [ :show, :edit, :update ]
  before_action -> { authorize_edit!(@customer) }, only: [ :edit, :update ]

  def index
    @q = Customer.readable.ransack(params[:q], auth_object: :customer_list)
    @pagy, @customers = pagy(@q.result.order(:name))
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: "顧客を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    # Interaction は公開範囲を持たず demo 境界だけなので、readable な親から辿る限り境界は保たれる。
    @interactions = @customer.interactions.order(occurred_at: :desc)
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "顧客情報を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_customer
    @customer = Customer.readable.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :key_notes)
  end
end
