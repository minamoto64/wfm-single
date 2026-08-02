class NoticesController < ApplicationController
  include Authorizable

  before_action :set_notice, only: %i[edit update]
  before_action :set_notice_with_comments, only: :show
  before_action -> { authorize_edit!(@notice) }, only: %i[edit update]

  def index
    @q = readable_notices.ransack(params[:q])
    @pagy, @notices = pagy(
      @q.result
        .preload(:user)
        .order(start_at: :desc)
    )
    @notices_by_root = Notice.related_records_by_root(
      @notices.map(&:root_id),
      preload: [ :user ]
    )
  end

  def new
    @parent_notice = Notice.readable.find(params[:parent_id]) if params[:parent_id].present?
    @notice = Notice.new(parent: @parent_notice)
  end

  def create
    @parent_notice = Notice.readable.find(params[:parent_id]) if params[:parent_id].present?
    @notice = Current.user.notices.build(create_notice_params)
    @notice.parent = @parent_notice

    if @notice.save
      if params[:interaction_id].present?
        @notice.interactions << Interaction.readable.find(params[:interaction_id])
      end

      @notice.tasks << Task.readable.find(params[:task_id]) if params[:task_id].present?

      redirect_to @notice, notice: "お知らせを更新しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @timeline = @notice.related_records
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
    @notice = Notice.readable.preload(:user).find(params[:id])
  end

  def set_notice_with_comments
    @notice = Notice.readable.preload(:user, comments: [ :user ]).find(params[:id])
  end

  def readable_notices
    Notice.readable
  end

  def notice_params
    params.require(:notice).permit(:title, :content, :level, :start_at, :end_at, images: [])
  end

  # 公開範囲は新規作成時にのみ admin が選択できる。作成後は変更できない。
  def create_notice_params
    return notice_params unless Current.user.admin?

    notice_params.merge(params.require(:notice).permit(:restricted))
  end
end
