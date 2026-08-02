module Authorizable
  extend ActiveSupport::Concern

  private

  # 拒否時はそのレコードの詳細へ返す。
  # 詳細画面を持たないリソースは fallback で戻り先を明示する。
  def authorize_edit!(record, fallback: record)
    return if record.editable?

    redirect_to fallback, alert: "編集権限がありません"
  end
end
