class Interaction < ApplicationRecord
  include Rootable
  rootable order_column: :occurred_at

  before_validation :set_customer_from_parent

  belongs_to :customer
  belongs_to :user

  has_many :interaction_notices
  has_many :notices, through: :interaction_notices

  has_many :interaction_tasks
  has_many :tasks, through: :interaction_tasks

  has_many :comments, as: :commentable
  has_many_attached :images

  enum :channel, {
    phone: "phone",
    email: "email",
    web: "web",
    sns: "sns",
    in_person: "in_person"
  }

  validates :occurred_at, presence: true
  validates :channel, presence: true
  validates :request_content, presence: true
  validates :response_result, presence: true
  validates :completed, inclusion: { in: [ true, false ] }
  validates :images,
    content_type: %w[image/jpeg image/png image/gif],
    size: { less_than_or_equal_to: 10.megabytes }

  private

  def set_customer_from_parent
    self.customer ||= parent&.customer
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[channel completed occurred_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[customer user]
  end
end
