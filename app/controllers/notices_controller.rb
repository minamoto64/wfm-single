class NoticesController < ApplicationController
  before_action :set_notice, only: %i[edit update]
  before_action :set_notice_with_comments, only: :show
  before_action :authorize_view!, only: %i[show edit update]
  before_action :authorize_edit!, only: %i[edit update]


  def index
    @q = visible_notices.ransack(params[:q], auth_object: :admin)
    @pagy, @notices = pagy(
      @q.result
        .preload(
          :user,
          root: {
            rooted_notices: [ :user ]
          }
        )
        .order(start_at: :desc)
    )
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

      @notice.tasks << Task.find(params[:task_id]) if params[:task_id].present?

      redirect_to @notice, notice: "お知らせを更新しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @timeline = @notice.root.rooted_notices.order(:created_at)
  end

  def edit
  end

  def update
    if @notice.update(notice_params)
      redirect_to @notice, notice: "お知らせを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_notice
    @notice = Notice.preload(:user).find(params[:id])
  end

  def set_notice_with_comments
    @notice = Notice.preload(:user, comments: [ :user ]).find(params[:id])
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
      images: []
    ]

    permitted << :restricted if Current.user.admin?

    params.require(:notice).permit(*permitted, images: [])
  end
end
