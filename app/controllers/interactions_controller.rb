class InteractionsController < ApplicationController
  include Authorizable

  before_action :set_interaction, only: [ :edit, :update ]
  before_action :set_interaction_with_comments, only: :show
  before_action -> { authorize_edit!(@interaction) }, only: [ :edit, :update ]

  def index
    @q = Interaction.accessible.ransack(params[:q])
    @pagy, @interactions = pagy(
      @q.result
        .preload(
          :customer,
          :user,
          root: {
            rooted_interactions: [ :customer, :user ]
          }
        )
        .order(occurred_at: :desc)
    )
  end

  def new
    @parent_interaction = Interaction.accessible.find_by(id: params[:parent_id])
    @interaction = Interaction.new(
      parent: @parent_interaction,
      customer: @parent_interaction&.customer
    )
  end

  def create
    @parent_interaction = Interaction.accessible.find_by(id: params[:parent_id])
    @interaction = Current.user.interactions.build(interaction_params)
    @interaction.parent = @parent_interaction
    @interaction.customer = @parent_interaction ? @parent_interaction.customer : accessible_customer

    if @interaction.save
      redirect_to @interaction, notice: "応対履歴を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @timeline = @interaction.root.rooted_interactions.order(:occurred_at)
  end

  def edit
  end

  def update
    if @interaction.update(interaction_params)
      redirect_to @interaction, notice: "応対履歴を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_interaction
    @interaction = Interaction.accessible.preload(:customer, :user).find(params[:id])
  end

  def set_interaction_with_comments
    @interaction = Interaction.accessible.preload(:customer, :user, comments: [ :user ]).find(params[:id])
  end

  def interaction_params
    params.require(:interaction).permit(
      :channel,
      :occurred_at,
      :request_content,
      :response_result,
      :completed,
      images: []
    )
  end

  def accessible_customer
    Customer.accessible.find_by(id: params[:customer_id])
  end
end
