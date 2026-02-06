class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  has_many :interactions
  has_many :notices
  has_many :created_tasks, class_name: "Task", foreign_key: "created_by_user_id"

  has_many :task_assignments
  has_many :assigned_tasks, through: :task_assignments, source: :task
end
