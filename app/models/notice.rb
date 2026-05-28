class Notice < ApplicationRecord
  before_validation :assign_root
  after_create :assign_self_as_root

  belongs_to :user

  belongs_to :parent, class_name: "Notice", optional: true
  has_many :children, class_name: "Notice", foreign_key: "parent_id"

  belongs_to :root, class_name: "Notice", optional: true
  has_many :thread_notices, class_name: "Notice", foreign_key: :root_id, dependent: :nullify

  has_many :interaction_notices
  has_many :interactions, through: :interaction_notices

  has_many :notice_tasks
  has_many :tasks, through: :notice_tasks

  has_many :comments, as: :commentable

  enum :level, {
    important: "important",
    normal: "normal"
  }

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true,  length: { maximum: 2000 }
  validates :level, presence: true
  validates :restricted, inclusion: { in: [ true, false ] }
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :end_at, comparison: { greater_than: :start_at }, if: -> { start_at.present? && end_at.present? }

  private

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end
end
