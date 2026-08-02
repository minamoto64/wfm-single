class User < ApplicationRecord
  include DemoScoped

  DEMO_LOGIN_EMAIL = "demo@example.com"

  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :interactions
  has_many :notices
  has_many :tasks

  has_many :task_assignments
  has_many :assigned_tasks, through: :task_assignments, source: :task

  has_many :comments

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
  validate :admin_must_not_change, on: :update

  scope :readable, -> { demo(Current.demo?) }

  # 従業員情報のため admin のみ編集可。
  def editable?
    Current.user&.admin?
  end

  private

  # 権限は新規登録時にのみ選択できる。降格・昇格の両方を止める。
  # 降格すると管理者限定のタスク・お知らせに到達できなくなり、
  # 昇格を許すと「作成時は admin だった」という前提で通した
  # Restrictable の検証（restricted_must_be_owned_by_admin）を後追いで崩せるため。
  # 既存アカウントへの管理者付与はアプリからは行えない。
  def admin_must_not_change
    return unless admin_changed?

    errors.add(:admin, "は登録後に変更できません")
  end

  # auth_object は「どの一覧画面から検索しているか」を表す。
  # 他モデルの関連を辿った検索では渡らないため、メールアドレス等は開放されない。
  def self.ransackable_attributes(auth_object = nil)
    base = %w[name]
    auth_object == :user_list ? base + %w[email_address admin] : base
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
