class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update ]

  def index
    @q = Customer.ransack(params[:q], auth_object: :customer_list)
    @customers = @q.result.order(:name)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to @customer, notice: "顧客を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "顧客情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :key_notes)
  end
end
