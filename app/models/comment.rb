class Comment < ApplicationRecord
  include DemoScoped

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  scope :readable, -> { demo(Current.demo?) }

  validates :content, presence: true, length: { maximum: 200 }
end
