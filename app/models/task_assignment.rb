class TaskAssignment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }, default: :todo

  validates :task_id, uniqueness: { scope: :user_id }

  private

  def self.ransackable_attributes(auth_object = nil)
    %w[status user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
