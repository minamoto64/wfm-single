class Customer < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A0\d{1,4}-\d{1,4}-\d{4}\z/ }, allow_blank: true
  validates :key_notes, length: { maximum: 500 }

  # add associations after other models are created
  # has_many :interactions
end
