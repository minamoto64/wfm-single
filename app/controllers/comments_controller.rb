class CommentsController < ApplicationController
  COMMENTABLES =  {
    "Interaction" => Interaction,
    "Task" => Task,
    "Notice" => Notice
  }.freeze

  before_action :set_commentable, only: [ :create ]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      redirect_to @commentable, notice: "コメントを投稿しました。"
    else
      redirect_to @commentable, alert: "コメントの投稿に失敗しました。"
    end
  end

  private

  def set_commentable
    klass = COMMENTABLES[params[:commentable_type]]

    raise ActiveRecord::RecordNotFound unless klass

    @commentable = klass.find(params[:commentable_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
