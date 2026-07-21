class TasksController < ApplicationController
  before_action :set_task, only: [ :edit, :update ]
  before_action :set_task_with_associations, only: :show
  before_action :authorize_view!, only: [ :show, :edit, :update ]
  before_action :authorize_edit!, only: [ :edit, :update ]

  def index
    @q = visible_tasks.ransack(params[:q], auth_object: :admin)
    @pagy, @tasks = pagy(
      @q.result
        .preload(
          :user,
          task_assignments: [ :user ],
          root: {
            thread_tasks: [ :user, task_assignments: [ :user ] ]
          }
        )
        .order(due_at: :asc)
    )
  end

  def new
    @parent_task = Task.find_by(id: params[:parent_id])
    @task = Task.new(parent: @parent_task)
    @form = TaskForm.new(task: @task)
  end

  def create
    @task = Current.user.tasks.build(task_params)
    @parent_task = @task.parent

    @form = TaskForm.new(
      task:           @task,
      assignee_ids:   params[:assignee_ids],
      interaction_id: params[:interaction_id],
      notice_id:      params[:notice_id]
    )

    if @form.save
      redirect_to @task, notice: "タスクを登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @timeline = @task.root.thread_tasks.order(:created_at)
  end

  def edit
    @form = TaskForm.new(task: @task)
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "タスクを更新しました"
    else
      @form = TaskForm.new(task: @task)
      @form.valid? # task.errors を form.errors に取り込む
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_task
    @task = Task.preload(:user).find(params[:id])
  end

  def set_task_with_associations
    @task = Task.preload(:user, task_assignments: [ :user ], comments: [ :user ]).find(params[:id])
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
    permitted = [
      :title,
      :description,
      :due_at,
      :parent_id
    ]
    permitted << :restricted if Current.user.admin?
    params.require(:task).permit(*permitted, images: [])
  end
end
