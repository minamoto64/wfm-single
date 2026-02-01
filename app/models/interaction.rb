class Interaction < ApplicationRecord
  belongs_to :customer
  belongs_to :user

  belongs_to :parent, class_name: "Interaction", foreign_key: "parent_interaction_id", optional: true
  has_many :children, class_name: "Interaction", foreign_key: "parent_interaction_id"

  # add associations after other models are created
  # has_many :notices
  # has_many :tasks

  enum :interaction_type, %i[phone email web sns in_person]

  validates :occurred_at, presence: true
  validates :interaction_type, presence: true
  validates :request_content, presence: true
  validates :response_result, presence: true
  validates :completed, inclusion: { in: [true, false] }
end
