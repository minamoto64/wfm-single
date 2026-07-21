module Authorizable
  extend ActiveSupport::Concern

  private

  def authorize_edit!(record)
    return if record.user == Current.user

    redirect_to record, alert: "編集権限がありません"
  end

  def authorize_view!(record, redirect_path)
    return if Current.user.admin? || !record.restricted

    redirect_to redirect_path, alert: "閲覧権限がありません"
  end
end
