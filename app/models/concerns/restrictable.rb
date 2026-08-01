module Restrictable
  extend ActiveSupport::Concern

  included do
    scope :not_restricted, -> { Current.user&.admin? ? all : where(restricted: false) }
  end
end
