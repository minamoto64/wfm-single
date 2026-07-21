class Task < ApplicationRecord
  include Rootable
  rootable order_column: :created_at

  belongs_to :user

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

  scope :due_within, ->(period) {
    from = Time.current.beginning_of_day
    case period
    when "unset" then where(due_at: nil)
    when "overdue" then where(due_at: ...Time.current.beginning_of_day)
    when "today" then where(due_at: from..Time.current.end_of_day)
    when "week"  then where(due_at: from..Time.current.end_of_week.end_of_day)
    when "month" then where(due_at: from..Time.current.end_of_month.end_of_day)
    else all
    end
  }

  def self.ransackable_attributes(auth_object = nil)
    base = %w[title description due_at]
    auth_object == :admin ? base + %w[restricted] : base
  end

  def self.ransackable_associations(auth_object = nil)
    %w[task_assignments user]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w[due_within]
  end
end
