module Rootable
  extend ActiveSupport::Concern

  included do
    before_validation :assign_root
    after_create :assign_self_as_root

    belongs_to :parent, class_name: name, optional: true
    belongs_to :root, class_name: name, optional: true
  end

  class_methods do
    # 一覧画面用。複数レコードの関連を root_id の IN 1本でまとめて引き、
    # root_id をキーにした Hash で返す。自分自身の除外は呼び出し側で行う。
    # nil を除くのは、root_id が nil のレコード同士が互いの関連として現れるのを防ぐため。
    def related_records_by_root(root_ids, preload: [])
      readable
        .where(root_id: root_ids.compact.uniq)
        .preload(preload)
        .order(root_order_column)
        .group_by(&:root_id)
    end
  end

  # 自分と同じ root に属する全レコード。自分自身を含む。
  # readable 経由なので権限境界はここで閉じる。
  def related_records
    self.class.readable
      .where(root_id: root_id)
      .order(self.class.root_order_column)
  end

  private

  def assign_root
    return unless parent

    self.root = parent.root || parent
  end

  def assign_self_as_root
    update_column(:root_id, id) if root_id.nil?
  end
end
