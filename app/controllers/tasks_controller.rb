class TasksController < ApplicationController
  include Authorizable

  before_action :set_task, only: [ :edit, :update ]
  before_action :set_task_with_associations, only: :show
  before_action -> { authorize_edit!(@task) }, only: [ :edit, :update ]

  def index
    @q = readable_tasks.ransack(params[:q])
    @pagy, @tasks = pagy(
      @q.result
        .preload(:user, task_assignments: [ :user ])
        .order(due_at: :asc)
    )
    @tasks_by_root = Task.related_records_by_root(
      @tasks.map(&:root_id),
      preload: [ :user, task_assignments: [ :user ] ]
    )
  end

  def new
    @parent_task = Task.readable.find(params[:parent_id]) if params[:parent_id].present?
    @task = Task.new(parent: @parent_task)
    @form = TaskForm.new(task: @task)
  end

  def create
    @parent_task = Task.readable.find(params[:parent_id]) if params[:parent_id].present?
    @task = Current.user.tasks.build(create_task_params)
    @task.parent = @parent_task

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
    @timeline = @task.related_records
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
    @task = Task.readable.preload(:user).find(params[:id])
  end

  def set_task_with_associations
    @task = Task.readable.preload(:user, task_assignments: [ :user ], comments: [ :user ]).find(params[:id])
  end

  def readable_tasks
    Task.readable
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_at, images: [])
  end

  # 公開範囲は新規作成時にのみ admin が選択できる。作成後は変更できない。
  def create_task_params
    return task_params unless Current.user.admin?

    task_params.merge(params.require(:task).permit(:restricted))
  end
end
