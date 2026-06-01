# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ==============================================================================
# パスワードの読み込み
# 本番環境では環境変数を必ず設定すること。
# 例: SEED_ADMIN_PASSWORD=xxxxx rails db:seed
# 開発・テスト環境ではデフォルト値 "password" にフォールバック。
# ==============================================================================
admin_password  = ENV.fetch("SEED_ADMIN_PASSWORD",  Rails.env.production? ? nil : "password")
admin2_password = ENV.fetch("SEED_ADMIN2_PASSWORD", Rails.env.production? ? nil : "password")
user_password   = ENV.fetch("SEED_USER_PASSWORD",   Rails.env.production? ? nil : "password")

if Rails.env.production? && [admin_password, admin2_password, user_password].any?(&:nil?)
  raise "本番環境ではSEED_ADMIN_PASSWORD / SEED_ADMIN2_PASSWORD / SEED_USER_PASSWORD の設定が必要です。"
end

# ==============================================================================
# 初期ユーザーの作成
# ==============================================================================
users_data = [
  {
    name: "管理者",
    email_address: "admin@example.com",
    password: admin_password,
    admin: true
  },
  {
    name: "管理者2",
    email_address: "admin2@example.com",
    password: admin2_password,
    admin: true
  },
  {
    name: "山田太郎",
    email_address: "yamada@example.com",
    password: user_password,
    admin: false
  },
  {
    name: "佐藤大樹",
    email_address: "satou@example.com",
    password: user_password,
    admin: false
  }
]

users_data.each do |attrs|
  user = User.find_or_create_by!(email_address: attrs[:email_address]) do |u|
    u.assign_attributes(attrs)
  end

  if user.previously_new_record?
    puts "初期ユーザーを作成しました！"
    puts "名前: #{user.name}"
    puts "メールアドレス: #{user.email_address}"
  end
end

# 以降でユーザーをメールアドレスで参照
user_admin  = User.find_by!(email_address: "admin@example.com")
user_admin2 = User.find_by!(email_address: "admin2@example.com")
user_yamada = User.find_by!(email_address: "yamada@example.com")
user_satou  = User.find_by!(email_address: "satou@example.com")

# ==============================================================================
# 初期顧客の作成
# ==============================================================================
customers_data = [
  {
    uuid: "11111111-1111-1111-1111-111111111111",
    name: "山田 花子",
    email: "hanako@example.com",
    phone: "090-1234-5678",
    key_notes: "初回訪問済み。次回は2月にフォロー予定。"
  },
  {
    uuid: "22222222-2222-2222-2222-222222222222",
    name: "佐藤 次郎",
    email: "",
    phone: "",
    key_notes: "メール・電話なし。家族経由で連絡。"
  },
  {
    uuid: "33333333-3333-3333-3333-333333333333",
    name: "John Smith",
    email: "john.smith@example.com",
    phone: "03-1234-5678",
    key_notes: "英語対応が必要。"
  },
  {
    uuid: "44444444-4444-4444-4444-444444444444",
    name: "山田 花子",
    email: "",
    phone: "",
    key_notes: "常連。"
  }
]

customers_data.each do |attrs|
  customer = Customer.find_or_create_by!(uuid: attrs[:uuid]) do |c|
    c.assign_attributes(attrs)
  end

  if customer.previously_new_record?
    puts "初期顧客を作成しました！"
    puts "名前: #{customer.name}"
    puts "UUID: #{customer.uuid}"
  end
end

# 以降で顧客をUUIDで参照
customer_hanako = Customer.find_by!(uuid: "11111111-1111-1111-1111-111111111111")
customer_jiro   = Customer.find_by!(uuid: "22222222-2222-2222-2222-222222222222")
customer_john   = Customer.find_by!(uuid: "33333333-3333-3333-3333-333333333333")

# ==============================================================================
# ヘルパーメソッド
# ==============================================================================
def interaction_status_label(completed)
  completed ? "完了" : "対応中"
end

def interaction_channel_label(channel)
  {
    phone: "電話",
    email: "メール",
    web: "WEB",
    sns: "SNS",
    in_person: "対面"
  }[channel.to_sym]
end

def notice_level_label(level)
  { important: "高", normal: "低" }[level.to_sym]
end

def task_status_label(status)
  { todo: "未着手", in_progress: "進行中", done: "完了" }[status.to_sym]
end

# ==============================================================================
# 初期応対履歴の作成
# ==============================================================================
interactions_data = [
  {
    customer: customer_hanako,
    user: user_admin2,
    occurred_at: Time.new(2026, 1, 26, 3, 3, 0, "+09:00"),
    channel: :phone,
    parent_key: nil,
    request_content: "商品Aの在庫問い合わせ。入荷したら連絡してほしいとのこと。",
    response_result: "在庫確認後、明日入荷予定と回答。入荷次第連絡する旨を伝えた。",
    completed: false
  },
  {
    customer: customer_hanako,
    user: user_admin2,
    occurred_at: Time.new(2026, 1, 30, 11, 0, 0, "+09:00"),
    channel: :phone,
    parent_key: 0, # インデックス0が親
    request_content: "入荷連絡の電話するも、不在。",
    response_result: "留守電にメッセージを入れて終話。",
    completed: false
  },
  {
    customer: customer_jiro,
    user: user_admin2,
    occurred_at: Time.new(2026, 1, 25, 2, 0, 0, "+09:00"),
    channel: :phone,
    parent_key: nil,
    request_content: "商品Xの不具合報告。一度店頭にて状況を確認してほしいとのこと。",
    response_result: "明日13時に来店予定。2階承りカウンターにお越しいただくように伝えてます。",
    completed: false
  },
  {
    customer: customer_john,
    user: user_yamada,
    occurred_at: Time.new(2026, 1, 31, 8, 0, 0, "+09:00"),
    channel: :in_person,
    parent_key: nil,
    request_content: "商品Bの取り寄せ依頼。",
    response_result: "センターにも在庫無。入荷まで2~3週間かかる旨伝える。入荷次第連絡希望。",
    completed: false
  }
]

created_interactions = []

interactions_data.each do |attrs|
  parent = attrs[:parent_key] ? created_interactions[attrs[:parent_key]] : nil

  interaction = Interaction.find_or_create_by!(
    customer: attrs[:customer],
    occurred_at: attrs[:occurred_at]
  ) do |i|
    i.user            = attrs[:user]
    i.channel         = attrs[:channel]
    i.parent          = parent
    i.request_content = attrs[:request_content]
    i.response_result = attrs[:response_result]
    i.completed       = attrs[:completed]
  end

  created_interactions << interaction

  if interaction.previously_new_record?
    puts "初期応対履歴を作成しました！"
    puts "顧客: #{interaction.customer.name}"
    puts "従業員: #{interaction.user.name}"
    puts "応対日時: #{interaction.occurred_at}"
    puts "問合せ方法: #{interaction_channel_label(interaction.channel)}"
  end
end

# ==============================================================================
# 初期周知事項の作成
# ==============================================================================
notices_data = [
  {
    key: :product_x_claim,
    title: "商品Xのクレーム多発について",
    content: "商品Xに関するクレームが増加しています。対応時は必ずマニュアルを確認し、丁寧な説明を心がけてください。不明点があれば必ず店長に確認してください。【対応のポイント】・まずお客様の話をしっかり聞く ・マニュアルP.15の手順に従う ・必要に応じて代替品を提案 ・対応後は必ず記録を残す ご協力よろしくお願いいたします。",
    level: :important,
    restricted: false,
    start_at: Time.new(2026, 2, 1, 11, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 11, 0, 0, "+09:00"),
    user: user_admin2,
    parent_key: nil
  },
  {
    key: :change_mistake,
    title: "お釣りのお渡し漏れについて",
    content: "最近レジでのお釣りを渡し忘れる事案が多発しています。お客様をお見送りするのも大事ですが、それよりも前にレジのトレーにお釣りやレシートが残っていないか、確認を徹底しましょう。",
    level: :normal,
    restricted: false,
    start_at: Time.new(2026, 2, 1, 13, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 13, 0, 0, "+09:00"),
    user: user_admin,
    parent_key: nil
  },
  {
    key: :card_return,
    title: "カードの返し忘れについて",
    content: "先日、レジでのお釣りの返し忘れが多い件について周知しましたが、今度はクレジットカードの返却忘れが発生しました。お釣りやレシートと同様ですが、お客様がクレジットカードをお取りいただいているか、カード決済端末も逐一確認するようお願いいたします。",
    level: :normal,
    restricted: false,
    start_at: Time.new(2026, 2, 2, 13, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 2, 13, 0, 0, "+09:00"),
    user: user_admin,
    parent_key: :change_mistake
  },
  {
    key: :retirement_request,
    title: "従業員の退職申出について",
    content: "Uターンするため、退職したいと佐藤さんから申し入れがありました。少し掘り下げると、直近の業務でしんどい部分があったことも影響しているようです。ひとまず慰留しましたが、元気がなさそうであれば声がけするなど、管理者各位もフォローお願いします。",
    level: :important,
    restricted: true,
    start_at: Time.new(2026, 2, 1, 12, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 12, 0, 0, "+09:00"),
    user: user_admin,
    parent_key: nil
  },
  {
    key: :retirement_hold,
    title: "退職申出の保留について",
    content: "佐藤さんとフォロー面談を実施した結果、もう少し将来についてゆっくり考えたいので、退職の話は一旦取り下げしたい都申出がありました。Uターンしてカフェを開業するという夢があるようです。全力で応援する気持ちと、現職で辛いことがあれば、管理者に気兼ねなく相談しても大丈夫と伝えてます。佐藤さんから何か相談があれば、快く相談にのってあげてください。",
    level: :important,
    restricted: true,
    start_at: Time.new(2026, 2, 3, 11, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 3, 11, 0, 0, "+09:00"),
    user: user_admin,
    parent_key: :retirement_request
  }
]

created_notices = {}

notices_data.each do |attrs|
  parent = attrs[:parent_key] ? created_notices[attrs[:parent_key]] : nil

  notice = Notice.find_or_create_by!(
    title: attrs[:title],
    start_at: attrs[:start_at],
    user: attrs[:user]
  ) do |n|
    n.content    = attrs[:content]
    n.level      = attrs[:level]
    n.restricted = attrs[:restricted]
    n.end_at     = attrs[:end_at]
    n.parent     = parent
  end

  created_notices[attrs[:key]] = notice

  if notice.previously_new_record?
    puts "初期周知事項を作成しました！"
    puts "タイトル: #{notice.title}"
    puts "種別: #{notice_level_label(notice.level)}"
  end
end

# ==============================================================================
# 初期タスクの作成
# ==============================================================================
tasks_data = [
  {
    key: :product_x_prevention,
    title: "商品X再発防止策の検討",
    description: "クレーム多発のため、メーカーとの協議と対応マニュアル改訂が必要。再発防止のための体制整備を行う。各店舗での対応事例を収集し、ベストプラクティスをまとめておいてください。",
    restricted: false,
    user: user_admin,
    parent_key: nil,
    due_at: Time.new(2026, 2, 12, 11, 0, 0, "+09:00")
  },
  {
    key: :maker_inquiry,
    title: "メーカーへの問い合わせ",
    description: "商品Xについてクレームが多発しているため、製造・設計段階で何か不具合があったのではないかメーカーへ確認要。佐藤さんが、各店舗での事例をExcelファイルにまとめてくれているので、そちらを添付の上、メーカーへメールにて問い合わせお願いします。不具合がないということであれば、今後の対応方法について助言を求めてください。",
    restricted: false,
    user: user_admin,
    parent_key: :product_x_prevention,
    due_at: Time.new(2026, 2, 9, 11, 0, 0, "+09:00")
  },
  {
    key: :manual_revision,
    title: "販売マニュアルの改訂",
    description: "メーカーから製造・設計段階による具体的な不具合は確認されなかったと返答。しかしながら、今後リコールへ発展する可能性も考え、同様の申出があった場合は、故意の破損等を除いて、原則交換対応とする。商品Xのクレーム申出があった場合は、メーカーが用意した特設フォームへ情報の入力が必要なため、手順について、期間用途限定のマニュアルを、既存の販売マニュアルへ追加要。改訂作業お願いします。",
    restricted: true,
    user: user_admin,
    parent_key: :maker_inquiry,
    due_at: Time.new(2026, 2, 9, 11, 0, 0, "+09:00")
  },
  {
    key: :product_y_stocking,
    title: "商品Yの品出し",
    description: "昨日の閉店作業時間内に商品Yの品出しが終わりませんでした。すみませんが、朝番の方、商品Yの棚がスカスカになっているので、開店作業中に優先して品出しをお願いします。",
    restricted: false,
    user: user_yamada,
    parent_key: nil,
    due_at: nil
  },
  {
    key: :everyone,
    title: "扶養控除申告書の提出について",
    description: "今年も年末調整の時期がやってきました！つきましては、扶養控除申告書の提出が必要となります。書面は2Fの事務室に置いてあります。各自1部お取りいただき、期日までに提出をお願いいたします。何か不明点があれば管理者まで。",
    restricted: false,
    user: user_admin,
    parent_key: nil,
    due_at: Time.new(2026, 2, 14, 11, 0, 0, "+09:00")
  },
  {
    key: :admin_only,
    title: "管理者各位 期末評価について",
    description: "社長との1on1面談が実施されます。面談にあたり、今年度の自己評価表の提出が必要となります。業務システムの管理者項目、期末評価から、期日までに提出をお願いいたします。",
    restricted: true,
    user: user_admin,
    parent_key: nil,
    due_at: Time.new(2026, 2, 14, 11, 0, 0, "+09:00")
  }
]

created_tasks = {}

tasks_data.each do |attrs|
  parent = attrs[:parent_key] ? created_tasks[attrs[:parent_key]] : nil

  task = Task.find_or_create_by!(
    title: attrs[:title],
    user: attrs[:user],
    parent: parent
  ) do |t|
    t.description = attrs[:description]
    t.restricted  = attrs[:restricted]
    t.due_at      = attrs[:due_at]
  end

  created_tasks[attrs[:key]] = task

  if task.previously_new_record?
    puts "初期タスクを作成しました！"
    puts "タイトル: #{task.title}"
    puts "作成者: #{task.user.name}"
    puts "期限: #{task.due_at}"
  end
end

# ==============================================================================
# 初期タスク割り当ての作成
# ==============================================================================
task_assignments_data = [
  { task_key: :product_x_prevention, user: user_yamada,  status: :todo },
  { task_key: :maker_inquiry,        user: user_satou,   status: :todo },
  { task_key: :manual_revision,      user: user_admin2,  status: :todo },
  { task_key: :product_y_stocking,   user: user_satou,   status: :todo },
]

# 作成者を含めて、従業員全員に割り当てるタスク
User.find_each do |u|
  task_assignments_data << { task_key: :everyone, user: u, status: :todo }
end

# 作成者を含めて、管理者権限を持つ全員に割り当てるタスク
User.where(admin: true).find_each do |u|
  task_assignments_data << { task_key: :admin_only, user: u, status: :todo }
end

task_assignments_data.each do |attrs|
  task = created_tasks[attrs[:task_key]]
  next unless task

  assignment = TaskAssignment.find_or_create_by!(
    task: task,
    user: attrs[:user]
  ) do |a|
    a.status = attrs[:status]
  end

  if assignment.previously_new_record?
    puts "初期タスク割り当てを作成しました"
    puts "タスク: #{assignment.task.title}"
    puts "担当: #{assignment.user.name}"
    puts "状態: #{task_status_label(assignment.status)}"
  end
end
