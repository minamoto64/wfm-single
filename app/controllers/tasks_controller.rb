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

    assignee_ids = Array(params[:assignee_ids]).reject(&:blank?)

    @task.valid?

    @task.errors.add(:base, "担当者を1人以上選択してください") if assignee_ids.empty?

    if @task.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      @task.save!

      @task.interactions << Interaction.find(params[:interaction_id]) if params[:interaction_id].present?
      @task.notices << Notice.find(params[:notice_id]) if params[:notice_id].present?

      assignee_ids.each do |user_id|
        @task.task_assignments.create!(user_id: user_id, status: :todo)
      end
    end

    redirect_to @task, notice: "タスクを登録しました"
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
    @task = Task.preload(
      :user,
      task_assignments: [ :user ],
      comments: [ :user ]
    ).find(params[:id])
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
