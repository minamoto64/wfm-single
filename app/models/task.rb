class Task < ApplicationRecord
  before_validation :assign_root
  after_create :assign_self_as_root

  belongs_to :user

  belongs_to :parent, class_name: "Task", optional: true
  has_many :children, class_name: "Task", foreign_key: "parent_id"

  belongs_to :root, class_name: "Task", optional: true
  has_many :thread_tasks, class_name: "Task", foreign_key: :root_id, dependent: :nullify

  has_many :task_assignments
  has_many :assigned_users, through: :task_assignments, source: :user

  has_many :interaction_tasks
  has_many :interactions, through: :interaction_tasks

  has_many :notice_tasks
  has_many :notices, through: :notice_tasks

  has_many :comments, as: :commentable
  has_many_attached :images

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :restricted, inclusion: { in: [ true, false ] }
  validates :images,
    content_type: %w[image/jpeg image/png image/gif],
    size: { less_than_or_equal_to: 10.megabytes }

  private

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end
end
