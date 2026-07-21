class InteractionsController < ApplicationController
  before_action :set_interaction, only: [ :edit, :update ]
  before_action :set_interaction_with_comments, only: :show
  before_action :authorize_edit!, only: [ :edit, :update ]

  def index
    @q = Interaction.ransack(params[:q])
    @pagy, @interactions = pagy(
      @q.result
        .preload(
          :customer,
          :user,
          root: {
            thread_interactions: [ :customer, :user ]
          }
        )
        .order(occurred_at: :desc)
    )
  end

  def new
    @parent_interaction = Interaction.find_by(id: params[:parent_id])
    @interaction = Interaction.new(
      parent: @parent_interaction,
      customer: @parent_interaction&.customer
    )
  end

  def create
    @interaction = Current.user.interactions.build(interaction_params)
    @parent_interaction = @interaction.parent

    if @interaction.save
      redirect_to @interaction, notice: "応対履歴を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @timeline = @interaction.root.thread_interactions.order(:occurred_at)
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
    @interaction = Interaction.preload(:customer, :user).find(params[:id])
  end

  def set_interaction_with_comments
    @interaction = Interaction.preload(:customer, :user, comments: [ :user ]).find(params[:id])
  end

  def interaction_params
    params.require(:interaction).permit(
      :customer_id, :channel, :occurred_at,
      :request_content, :response_result, :completed, :parent_id,
      images: []
    )
  end

  def authorize_edit!
    return if @interaction.user == Current.user

    redirect_to @interaction, alert: "編集権限がありません"
  end
end
