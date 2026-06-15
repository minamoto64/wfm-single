class Interaction < ApplicationRecord
  before_validation :assign_root
  before_validation :set_customer_from_parent
  after_create :assign_self_as_root

  belongs_to :customer
  belongs_to :user

  belongs_to :parent, class_name: "Interaction", optional: true
  has_many :children, class_name: "Interaction", foreign_key: "parent_id"

  belongs_to :root, class_name: "Interaction", optional: true
  has_many :thread_interactions, class_name: "Interaction", foreign_key: :root_id, dependent: :nullify

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

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def set_customer_from_parent
    self.customer ||= parent&.customer
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[channel completed occurred_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[customer user]
  end
end
