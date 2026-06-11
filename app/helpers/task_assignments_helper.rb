module TaskAssignmentsHelper
  def task_status_label(assignment)
    I18n.t("enums.task_assignment.status.#{assignment.status}")
  end
end
