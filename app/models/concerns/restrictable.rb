module Restrictable
  extend ActiveSupport::Concern

  included do
    scope :not_restricted, -> { Current.user&.admin? ? all : where(restricted: false) }

    before_validation :inherit_restricted_from_parent, on: :create

    validates :restricted, inclusion: { in: [ true, false ] }
    validate :restricted_must_be_owned_by_admin, on: :create
    validate :restricted_must_not_change, on: :update
  end

  private

  # 管理者限定のレコードにぶら下がる関連は、必ず親と同じ公開範囲にする。
  # 関連だけが公開されると、一連の関連の一部だけが意図せず全員に見える状態になるため。
  # 公開範囲は作成後に変更できないので、親を見て決まる方が扱いも一貫する。
  def inherit_restricted_from_parent
    return unless parent&.restricted?

    self.restricted = true
  end

  # 公開範囲を絞ったレコードは admin しか閲覧できない（readable）。
  # 非 admin が作成すると作成者自身が到達できないレコードになるため、
  # コントローラの許可属性だけに頼らずモデル側でも禁止する。
  def restricted_must_be_owned_by_admin
    return unless restricted?
    return if user&.admin?

    errors.add(:restricted, "は管理者のみ設定できます")
  end

  # 公開範囲は新規作成時にのみ選択できる。
  # 後から切り替えると、担当者が到達できないタスクが生じたり、
  # 既に閲覧された内容を事後的に秘匿することになるため。
  def restricted_must_not_change
    return unless restricted_changed?

    errors.add(:restricted, "は作成後に変更できません")
  end
end
