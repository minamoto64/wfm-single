class Task < ApplicationRecord
  include Rootable
  include DemoScoped
  include Restrictable

  def self.root_order_column
    :created_at
  end

  belongs_to :user

  has_many :task_assignments
  has_many :assigned_users, through: :task_assignments, source: :user

  has_many :interaction_tasks
  has_many :interactions, through: :interaction_tasks

  has_many :notice_tasks
  has_many :notices, through: :notice_tasks

  has_many :comments, as: :commentable
  has_many_attached :images

  scope :readable, -> { demo(Current.demo?).not_restricted }

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :images,
    content_type: %w[image/jpeg image/png image/gif],
    size: { less_than_or_equal_to: 10.megabytes }

  # 編集は作成者本人のみ。admin も改ざん防止のため対象外。
  def editable?
    user == Current.user
  end

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

  # 検索フォームに出せる項目の宣言。閲覧境界は readable が持つ。
  def self.ransackable_attributes(auth_object = nil)
    base = %w[title description due_at]
    Current.user&.admin? ? base + %w[restricted] : base
  end

  def self.ransackable_associations(auth_object = nil)
    %w[task_assignments user]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w[due_within]
  end
end
