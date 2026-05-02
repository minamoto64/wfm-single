class InteractionsController < ApplicationController
  before_action :set_interaction, only: [ :show, :edit, :update ]

  def index
    @interactions = Interaction
                      .preload(:customer, :user)
                      .order(occurred_at: :desc)
  end

  def new; end
  def create; end
  def show; end
  def edit; end
  def update; end

  private

  def set_interaction
    @interaction = Interaction.find(params[:id])
  end

  def interaction_params
    params.require(:interaction).permit(
      :customer_id, :channel, :occurred_at,
      :request_content, :response_result, :completed, :parent_id,
      images: []
    )
  end
end
