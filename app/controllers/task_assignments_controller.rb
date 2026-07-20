class TaskAssignmentsController < ApplicationController
  before_action :set_task_assignment
  before_action :authorize_owner!

  def update
    if @task_assignment.update(task_assignment_params)
      redirect_to @task_assignment.task, notice: "進捗状況を更新しました"
    else
      redirect_to @task_assignment.task, alert: "進捗状況の更新に失敗しました"
    end
  end

  private

  def set_task_assignment
    @task_assignment = TaskAssignment.find(params[:id])
  end

  def authorize_owner!
    return if @task_assignment.user == Current.user

    redirect_to @task_assignment.task, alert: "更新権限がありません"
  end

  def task_assignment_params
    params.require(:task_assignment).permit(:status)
  end
end
