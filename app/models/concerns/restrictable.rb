module Restrictable
  extend ActiveSupport::Concern

  included do
    scope :visible, -> { Current.user&.admin? ? all : where(restricted: false) }
  end
end
