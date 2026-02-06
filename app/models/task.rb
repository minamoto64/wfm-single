class Task < ApplicationRecord
  belongs_to :created_by_user, class_name: "User"

  belongs_to :parent, class_name: "Task", foreign_key: "parent_task_id", optional: true
  has_many :children, class_name: "Task", foreign_key: "parent_task_id"

  # add associations after other models are created
  # has_many :task_assignments

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :admin_only, inclusion: { in: [ true, false ] }
end
