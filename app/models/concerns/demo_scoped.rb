module DemoScoped
  extend ActiveSupport::Concern

  included do
    scope :demo, ->(flag) { where(demo: flag) }

    before_validation :assign_demo_flag, on: :create
  end

  private

  # Current.demo? を明示的に呼ばない限りdemo/本番の境界は反映されない。
  # 呼び出し側がdemoを明示指定した場合（シード等）はそちらを優先する。
  def assign_demo_flag
    self.demo = Current.demo? unless demo_changed?
  end
end
