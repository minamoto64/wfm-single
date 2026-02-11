class Notice < ApplicationRecord
  belongs_to :user

  belongs_to :parent, class_name: "Notice", optional: true
  has_many :children, class_name: "Notice", foreign_key: "parent_id"

  # add associations after other models are created
  # has_many :interactions
  # has_many :tasks

  enum :level, {
    important: "important",
    normal: "normal",
    confidential: "confidential"
  }

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true,  length: { maximum: 2000 }
  validates :level, presence: true
  validates :restricted, inclusion: { in: [ true, false ] }
  validates :start_at, presence: true
  validates :end_at, presence: true, comparison: { greater_than: :start_at }
end
