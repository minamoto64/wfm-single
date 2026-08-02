class TaskAssignment < ApplicationRecord
  include DemoScoped

  belongs_to :task
  belongs_to :user

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }, default: :todo

  # 従属リソースのため、親タスクの閲覧境界をそのまま引き継ぐ。
  scope :readable, -> { demo(Current.demo?).joins(:task).merge(Task.readable) }

  validates :task_id, uniqueness: { scope: :user_id }
  validate :assignee_must_be_admin, if: -> { task&.restricted? }

  # 編集は担当者本人のみ。admin も改ざん防止のため対象外。
  def editable?
    user == Current.user
  end

  private

  # 管理者限定タスクは admin しか閲覧できないため、
  # 非 admin を担当者にすると「割り当てられているが見えないタスク」が生まれる。
  def assignee_must_be_admin
    return if user.blank? || user.admin?

    errors.add(:user, "は管理者限定タスクの担当者にできません")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[status user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
