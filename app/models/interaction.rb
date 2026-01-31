class Interaction < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  belongs_to :parent_interaction
end
