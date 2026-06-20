class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :interactions
  has_many :notices
  has_many :tasks

  has_many :task_assignments
  has_many :assigned_tasks, through: :task_assignments, source: :task

  has_many :comments

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  private

  def self.ransackable_attributes(auth_object = nil)
    base = %w[name]
    auth_object == :user_list ? base + %w[email_address admin] : base
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
