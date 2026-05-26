class InteractionNotice < ApplicationRecord
  belongs_to :interaction
  belongs_to :notice
end
