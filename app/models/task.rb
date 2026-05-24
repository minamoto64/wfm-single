class Task < ApplicationRecord
  before_validation :assign_root
  after_create :assign_self_as_root

  belongs_to :user

  belongs_to :parent, class_name: "Task", optional: true
  has_many :children, class_name: "Task", foreign_key: "parent_id"

  belongs_to :root, class_name: "Task", optional: true
  has_many :thread_tasks, class_name: "Task", foreign_key: :root_id, dependent: :nullify

  # add associations after other models are created
  has_many :task_assignments
  has_many :assigned_users, through: :task_assignments, source: :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :restricted, inclusion: { in: [ true, false ] }

  private

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end
end
