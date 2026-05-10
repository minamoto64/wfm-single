class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update ]

  def index
    @customers = Customer.order(:name)
  end

  def new; end
  def create; end
  def show; end
  def edit; end
  def update; end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :key_notes)
  end
end
