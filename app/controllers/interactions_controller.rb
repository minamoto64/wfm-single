class InteractionsController < ApplicationController
  before_action :set_interaction, only: [ :show, :edit, :update ]

  def index
    @interactions = Interaction
                      .preload(:customer, :user)
                      .order(occurred_at: :desc)
  end

  def new
    @interaction = Interaction.new
    @parent_interaction = Interaction.find_by(id: params[:parent_id])

    if @parent_interaction
      @interaction.parent = @parent_interaction
      @interaction.customer = @parent_interaction.customer
    end
  end

  def create
    @interaction = Current.user.interactions.new(interaction_params)

    if @interaction.save
      redirect_to @interaction, notice: "応対履歴を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    root = @interaction.parent || @interaction
    @timeline = [ root, *root.children ].sort_by(&:occurred_at)
  end

  def edit; end
  def update; end

  private

  def set_interaction
    @interaction = Interaction.preload(
      :customer,
      :user
    ).find(params[:id])
  end

  def interaction_params
    params.require(:interaction).permit(
      :customer_id, :channel, :occurred_at,
      :request_content, :response_result, :completed, :parent_id,
      images: []
    )
  end
end
