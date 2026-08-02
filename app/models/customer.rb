class Customer < ApplicationRecord
  include DemoScoped

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, format: { with: /\A0\d{1,4}-\d{1,4}-\d{4}\z/ }, allow_blank: true
  validates :key_notes, length: { maximum: 500 }

  # add associations after other models are created
  has_many :interactions

  scope :readable, -> { demo(Current.demo?) }

  # 顧客情報は業務の核であり、都度の許可申請では現場が回らないため全員編集可。
  # 認証済みなら常に true になるため、呼び出し側のガードは通過専用。
  # それでも他リソースと同じ形で書くのは、後から条件を絞るときの入口を1箇所に保つため。
  def editable?
    Current.user.present?
  end

  # auth_object は「どの一覧画面から検索しているか」を表す。
  # 他モデルの関連を辿った検索では渡らないため、メールアドレス等は開放されない。
  def self.ransackable_attributes(auth_object = nil)
    base = %w[name phone]
    auth_object == :customer_list ? base + %w[email] : base
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
