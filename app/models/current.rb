class Current < ActiveSupport::CurrentAttributes
  attribute :session, :demo
  delegate :user, to: :session, allow_nil: true

  def demo?
    demo || false
  end
end
