class TaskAssignment < ApplicationRecord
  include DemoScoped

  belongs_to :task
  belongs_to :user

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }, default: :todo

  validates :task_id, uniqueness: { scope: :user_id }

  scope :readable, -> { demo(Current.demo?) }

  # 編集は担当者本人のみ。admin も改ざん防止のため対象外。
  def editable?
    user == Current.user
  end

  private

  def self.ransackable_attributes(auth_object = nil)
    %w[status user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
