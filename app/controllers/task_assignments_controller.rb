class TaskAssignmentsController < ApplicationController
  include Authorizable

  before_action :set_task_assignment
  # TaskAssignment に show ルートは無いため、親タスクの詳細へ返す。
  before_action -> { authorize_edit!(@task_assignment, fallback: @task_assignment.task) }

  def update
    if @task_assignment.update(task_assignment_params)
      redirect_to @task_assignment.task, notice: "進捗状況を更新しました"
    else
      redirect_to @task_assignment.task, alert: "進捗状況の更新に失敗しました"
    end
  end

  private

  def set_task_assignment
    @task_assignment = TaskAssignment.readable.find(params[:id])
  end

  def task_assignment_params
    params.require(:task_assignment).permit(:status)
  end
end
