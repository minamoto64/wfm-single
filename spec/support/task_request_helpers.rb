module TaskRequestHelpers
  def create_task_with_assignees(params, user: create(:user))
    params.merge(assignee_ids: [ user.id ])
  end
end
