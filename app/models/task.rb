class Task < ApplicationRecord
  belongs_to :user

  belongs_to :parent, class_name: "Task", optional: true
  has_many :children, class_name: "Task", foreign_key: "parent_id"

  # add associations after other models are created
  has_many :task_assignments
  has_many :assigned_users, through: :task_assignments, source: :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :restricted, inclusion: { in: [ true, false ] }
end
