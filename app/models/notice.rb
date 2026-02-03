class Notice < ApplicationRecord
  belongs_to :posted_by_user, class_name: "User"

  belongs_to :parent, class_name: "Notice", foreign_key: "parent_notice_id", optional: true
  has_many :children, class_name: "Notice", foreign_key: "parent_notice_id"

  # add associations after other models are created
  # has_many :interactions
  # has_many :tasks

  enum :notice_type, {
    important: "important",
    normal: "normal",
    confidential: "confidential"
  }

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true,  length: { maximum: 2000 }
  validates :notice_type, presence: true
  validates :admin_only, inclusion: { in: [ true, false ] }
  validates :start_at, presence: true
  validates :end_at, presence: true, comparison: { greater_than: :start_at }
end
