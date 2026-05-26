class NoticesController < ApplicationController
  before_action :set_notice, only: %i[show edit update]
  before_action :authorize_view!, only: %i[show edit update]
  before_action :authorize_edit!, only: %i[edit update]


  def index
    @notices = visible_notices.preload(:user).order(start_at: :desc)
  end

  def new
    @parent_notice = Notice.find_by(id: params[:parent_id])
    @notice = Notice.new(parent: @parent_notice)
  end

  def create
    @notice = Current.user.notices.build(notice_params)
    @parent_notice = @notice.parent

    if @notice.save
      if params[:interaction_id].present?
        @notice.interactions << Interaction.find(params[:interaction_id])
      end

      redirect_to @notice, notice: "お知らせを更新しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @timeline = @notice.root.thread_notices.order(:created_at)
  end

  def edit
  end

  def update
    if @notice.update(notice_params)
      redirect_to @notice, notice: "お知らせを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_notice
    @notice = Notice.preload(:user).find(params[:id])
  end

  def visible_notices
    Current.user.admin? ? Notice.all : Notice.where(restricted: false)
  end

  def authorize_view!
    return if Current.user.admin? || !@notice.restricted

    redirect_to notices_path, alert: "アクセス権限がありません"
  end

  def authorize_edit!
    return if @notice.user == Current.user

    redirect_to @notice, alert: "編集権限がありません"
  end

  def notice_params
    permitted = %i[
      title
      content
      level
      start_at
      end_at
      parent_id
    ]

    permitted << :restricted if Current.user.admin?

    params.require(:notice).permit(permitted)
  end
end
