class TaskForm
  include ActiveModel::Model

  attr_reader :task
  attr_accessor :assignee_ids, :interaction_id, :notice_id

  validate :task_must_be_valid
  validate :at_least_one_assignee, if: -> { task.new_record? }
  # 親から restricted を継承するのは task の before_validation なので、
  # このバリデーションの実行順に関係なく判定できるよう parent も見る。
  validate :assignees_must_be_admin, if: -> { task.restricted? || task.parent&.restricted? }

  def initialize(task:, assignee_ids: [], interaction_id: nil, notice_id: nil)
    @task           = task
    @assignee_ids   = Array(assignee_ids).reject(&:blank?).uniq
    @interaction_id = interaction_id
    @notice_id      = notice_id
  end

  def save
    return false unless valid?

    # TaskForm#save は新規作成のみを想定している。
    # 担当者の追加・削除・status変更を含む更新対応は別Issueで実装予定。
    raise "TaskForm#save does not support existing records yet" if task.persisted?

    ActiveRecord::Base.transaction do
      task.save!
      task.interactions << Interaction.readable.find(interaction_id) if interaction_id.present?
      task.notices      << Notice.readable.find(notice_id)            if notice_id.present?

      assignee_ids.each do |user_id|
        task.task_assignments.create!(user: User.readable.find(user_id), status: :todo)
      end
    end

    true
  end

  private

  # Task自身のバリデーション(title, description, restricted, images)を
  # TaskFormのエラーとして取り込む
  def task_must_be_valid
    return if task.valid?

    task.errors.each do |error|
      errors.add(:base, task.errors.full_message(error.attribute, error.message))
    end
  end

  # 新規作成時のみ、担当者が1人以上選択されているかチェック
  def at_least_one_assignee
    return if assignee_ids.any?
    errors.add(:base, "担当者を1人以上選択してください")
  end

  # TaskAssignment 側のバリデーションと同じ規則をフォームでも検証する。
  # ここで弾かないと save 内の create! が RecordInvalid を投げて500になる。
  # 管理者限定タスクの担当者は admin に限られる（TaskAssignment#assignee_must_be_admin）。
  def assignees_must_be_admin
    non_admins = User.readable.where(id: assignee_ids, admin: false)
    return if non_admins.empty?

    errors.add(:base, "管理者限定タスクには管理者以外を担当者に指定できません（#{non_admins.map(&:name).join('、')}）")
  end
end
