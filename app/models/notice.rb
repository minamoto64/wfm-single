class Notice < ApplicationRecord
  include Rootable
  rootable order_column: :created_at

  belongs_to :user

  has_many :interaction_notices
  has_many :interactions, through: :interaction_notices

  has_many :notice_tasks
  has_many :tasks, through: :notice_tasks

  has_many :comments, as: :commentable
  has_many_attached :images

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
  validates :images,
    content_type: %w[image/jpeg image/png image/gif],
    size: { less_than_or_equal_to: 10.megabytes }

  private

  scope :status, ->(value) {
    now = Time.current
    case value
    when "active" then where("start_at <= ? AND end_at >= ?", now, now)
    when "expired" then where("end_at < ?", now)
    else all
    end
  }

  def self.ransackable_attributes(auth_object = nil)
    base = %w[title content level start_at end_at]
    auth_object == :admin ? base + %w[restricted] : base
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  def self.ransackable_scopes(auth_object = nil)
    %w[status]
  end
end
