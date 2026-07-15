module TaskAssignmentsHelper
  def task_status_label(assignment)
    I18n.t("enums.task_assignment.status.#{assignment.status}")
  end

  def task_status_badge_class(assignment)
    base = "inline-flex items-center justify-center rounded text-xs border"

    color = case assignment.status
    when "todo" then "bg-gray-100 text-gray-600 border-gray-200"
    when "in_progress" then "bg-blue-100 text-blue-600 border-blue-200"
    when "done" then "bg-green-100 text-green-600 border-green-200"
    end

    "#{base} #{color}"
  end
end
