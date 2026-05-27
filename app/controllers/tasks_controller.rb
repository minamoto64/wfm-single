class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update ]
  before_action :authorize_view!, only: [ :show, :edit, :update ]
  before_action :authorize_edit!, only: [ :edit, :update ]

  def index
    @tasks = visible_tasks.preload(:user).order(due_at: :asc)
  end

  def new
    @parent_task = Task.find_by(id: params[:parent_id])
    @task = Task.new(parent: @parent_task)
  end

  def create
    @task = Current.user.tasks.build(task_params)
    @parent_task = @task.parent

    if @task.save
      if params[:interaction_id].present?
        @task.interactions << Interaction.find(params[:interaction_id])
      end

      if params[:notice_id].present?
        @task.notices << Notice.find(params[:notice_id])
      end

      redirect_to @task, notice: "タスクを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @timeline = @task.root.thread_tasks.order(:created_at)
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "タスクを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.preload(:user).find(params[:id])
  end

  def visible_tasks
    Current.user.admin? ? Task.all : Task.where(restricted: false)
  end

  def authorize_view!
    return if Current.user.admin? || !@task.restricted

    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def authorize_edit!
    return if @task.user == Current.user

    redirect_to @task, alert: "編集権限がありません"
  end

  def task_params
    permitted = %i[
      title
      description
      due_at
      parent_id
    ]

    permitted << :restricted if Current.user.admin?

    params.require(:task).permit(permitted)
  end
end
