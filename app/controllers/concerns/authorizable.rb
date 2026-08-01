module Authorizable
  extend ActiveSupport::Concern

  private

  def authorize_edit!(record)
    return if record.editable?

    redirect_to record, alert: "編集権限がありません"
  end
end
