# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 初期ユーザーの作成
users = [
  {
    name: "管理者",
    email_address: "admin@example.com",
    password: "password",
    password_confirmation: "password",
    admin: true
  },
  {
    name: "管理者2",
    email_address: "admin2@example.com",
    password: "password",
    password_confirmation: "password",
    admin: true
  },
  {
    name: "山田太郎",
    email_address: "yamada@example.com",
    password: "password",
    password_confirmation: "password",
    admin: false
  },
  {
    name: "佐藤大樹",
    email_address: "satou@example.com",
    password: "password",
    password_confirmation: "password",
    admin: false
  }
]

users.each do |attrs|
  user = User.find_or_create_by!(email_address: attrs[:email_address]) do |u|
    u.assign_attributes(attrs)
  end

  if user.previously_new_record?
    puts "初期ユーザーを作成しました！"
    puts "名前: #{user.name}"
    puts "メールアドレス: #{user.email_address}"
    puts "パスワード: password"
  end
end

# 初期顧客の作成
customers = [
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

customers.each do |attrs|
  customer = Customer.find_or_create_by!(uuid: attrs[:uuid]) do |u|
    u.assign_attributes(attrs)
  end

  if customer.previously_new_record?
    puts "初期顧客を作成しました！"
    puts "名前: #{customer.name}"
    puts "UUID #{customer.uuid}"
    puts "メールアドレス: #{customer.email}"
    puts "電話番号: #{customer.phone}"
    puts "重要メモ: #{customer.key_notes}"
  end
end

# 応対履歴のステータスを日本語に変換する
def interaction_status_label(completed)
  completed ? "完了" : "対応中"
end

# 応対履歴の問合せ方法を日本語に変換する
def interaction_channel_label(channel)
  {
    phone: "電話",
    email: "メール",
    web: "WEB",
    sns: "SNS",
    in_person: "対面"
  }[channel.to_sym]
end

# 初期応対履歴の作成
interactions = [
  {
    customer_id: 1,
    user_id: 2,
    occurred_at: Time.new(2026, 1, 26, 3, 3, 0, "+09:00"),
    channel: :phone,
    parent_id: nil,
    request_content: "商品Aの在庫問い合わせ。入荷したら連絡してほしいとのこと。",
    response_result: "在庫確認後、明日入荷予定と回答。 入荷次第連絡する旨を伝えた。",
    completed: false
  },
  {
    customer_id: 1,
    user_id: 2,
    occurred_at: Time.new(2026, 1, 30, 11, 0, 0, "+09:00"),
    channel: :phone,
    parent_id: 1,
    request_content: "入荷連絡の電話するも、不在。",
    response_result: "留守電にメッセージを入れて終話。",
    completed: false
  },
  {
    customer_id: 2,
    user_id: 2,
    occurred_at: Time.new(2026, 1, 25, 2, 0, 0, "+09:00"),
    channel: :phone,
    parent_id: nil,
    request_content: "商品Xの不具合報告。一度店頭にて状況を確認してほしいとのこと。",
    response_result: "明日13時に来店予定。2階承りカウンターにお越しいただくように伝えてます。",
    completed: false
  },
  {
    customer_id: 3,
    user_id: 3,
    occurred_at: Time.new(2026, 1, 31, 8, 0, 0, "+09:00"),
    channel: :in_person,
    parent_id: nil,
    request_content: "商品Bの取り寄せ依頼。",
    response_result: "センターにも在庫無。入荷まで2~3週間かかる旨伝える。入荷次第連絡希望。",
    completed: false
  }
]

interactions.each do |attrs|
  interaction = Interaction.find_or_create_by!(
    customer_id: attrs[:customer_id],
    occurred_at: attrs[:occurred_at]
  ) do |u|
    u.assign_attributes(attrs)
  end

  if interaction.previously_new_record?
    puts "初期応対履歴を作成しました！"
    puts "顧客: #{interaction.customer.name}"
    puts "従業員: #{interaction.user.name}"
    puts "応対日時: #{interaction.occurred_at}"
    puts "問合せ方法: #{interaction_channel_label(interaction.channel)}"
    puts "応対内容: #{interaction.request_content}"
    puts "対応結果: #{interaction.response_result}"
    puts "対応状況: #{interaction_status_label(interaction.completed)}"
  end
end

# 周知事項の種別を日本語に変換する
def notice_level_label(level)
  {
    important: "重要",
    normal: "通常",
    confidential: "管理者"
  }[level.to_sym]
end

# 初期の周知事項の作成
notices = [
  {
    title: "商品Xのクレーム多発について",
    content: "商品Xに関するクレームが増加しています。 対応時は必ずマニュアルを確認し、丁寧な説明を心がけてください。 不明点があれば必ず店長に確認してください。 【対応のポイント】 ・まずお客様の話をしっかり聞く ・マニュアルP.15の手順に従う ・必要に応じて代替品を提案 ・対応後は必ず記録を残す ご協力よろしくお願いいたします。",
    level: :important,
    restricted: false,
    start_at: Time.new(2026, 2, 1, 11, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 11, 0, 0, "+09:00"),
    user_id: 2,
    parent_id: nil
  },
  {
    title: "お釣りのお渡し漏れについて",
    content: "最近レジでのお釣りを渡し忘れる事案が多発しています。お客様をお見送りするのも大事ですが、それよりも前にレジのトレーにお釣りやレシートが残っていないか、確認を徹底しましょう。",
    level: :normal,
    restricted: false,
    start_at: Time.new(2026, 2, 1, 13, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 13, 0, 0, "+09:00"),
    user_id: 1,
    parent_id: nil
  },
  {
    title: "カードの返し忘れについて",
    content: "先日、レジでのお釣りの返し忘れが多い件について周知しましたが、今度はクレジットカードの返却忘れが発生しました。お釣りやレシートと同様ですが、お客様がクレジットカードをお取りいただいているか、カード決済端末も逐一確認するようお願いいたします。",
    level: :normal,
    restricted: false,
    start_at: Time.new(2026, 2, 2, 13, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 2, 13, 0, 0, "+09:00"),
    user_id: 1,
    parent_id: 3
  },
  {
    title: "従業員の退職申出について",
    content: "Uターンするため、退職したいと佐藤さんから申し入れがありました。少し掘り下げると、直近の業務でしんどい部分があったことも影響しているようです。ひとまず慰留しましたが、元気がなさそうであれば声がけするなど、管理者各位もフォローお願いします。",
    level: :confidential,
    restricted: true,
    start_at: Time.new(2026, 2, 1, 12, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 1, 12, 0, 0, "+09:00"),
    user_id: 1,
    parent_id: nil
  },
  {
    title: "退職申出の保留について",
    content: "佐藤さんとフォロー面談を実施した結果、もう少し将来についてゆっくり考えたいので、退職の話は一旦取り下げしたい都申出がありました。Uターンしてカフェを開業するという夢があるようです。全力で応援する気持ちと、現職で辛いことがあれば、管理者に気兼ねなく相談しても大丈夫と伝えてます。佐藤さんから何か相談があれば、快く相談にのってあげてください。",
    level: :confidential,
    restricted: true,
    start_at: Time.new(2026, 2, 3, 11, 0, 0, "+09:00"),
    end_at: Time.new(2026, 8, 3, 11, 0, 0, "+09:00"),
    user_id: 1,
    parent_id: 4
  }
]

notices.each do |attrs|
  notice = Notice.find_or_create_by!(
    title: attrs[:title],
    start_at: attrs[:start_at],
    user_id: attrs[:user_id]
  ) do |u|
    u.assign_attributes(attrs)
  end

  if notice.previously_new_record?
    puts "初期周知事項を作成しました！"
    puts "#{notice.title}"
    puts "内容: #{notice.content}"
    puts "種別: #{notice_level_label(notice.level)}"
    puts "作成日時: #{notice.start_at}"
    puts "終了日時: #{notice.end_at}"
    puts "作成者: #{notice.user.name}"
  end
end

# 初期タスクの作成
tasks = [
  {
    title: "商品X再発防止策の検討",
    description: "クレーム多発のため、メーカーとの協議と対応マニュアル改訂が必要。 再発防止のための体制整備を行う。 各店舗での対応事例を収集し、ベストプラクティスをまとめておいてください。",
    restricted: false,
    user_id: 1,
    parent_id: nil,
    due_at: Time.new(2026, 2, 12, 11, 0, 0, "+09:00")
  },
  {
    title: "メーカーへの問い合わせ",
    description: "商品Xについてクレームが多発しているため、製造・設計段階で何か不具合があったのではないかメーカーへ確認要。佐藤さんが、各店舗での事例をExcelファイルにまとめてくれているので、そちらを添付の上、メーカーへメールにて問い合わせお願いします。不具合がないということであれば、今後の対応方法について助言を求めてください。",
    restricted: false,
    user_id: 1,
    parent_id: 1,
    due_at: Time.new(2026, 2, 9, 11, 0, 0, "+09:00")
  },
  {
    title: "販売マニュアルの改訂",
    description: "メーカーから製造・設計段階による具体的な不具合は確認されなかったと返答。しかしながら、今後リコールへ発展する可能性も考え、同様の申出があった場合は、故意の破損等を除いて、原則交換対応とする。商品Xのクレーム申出があった場合は、メーカーが用意した特設フォームへ情報の入力が必要なため、手順について、期間用途限定のマニュアルを、既存の販売マニュアルへ追加要。改訂作業お願いします。",
    restricted: true,
    user_id: 1,
    parent_id: 2,
    due_at: Time.new(2026, 2, 9, 11, 0, 0, "+09:00")
  },
  {
    title: "商品Yの品出し",
    description: "昨日の閉店作業時間内に商品Yの品出しが終わりませんでした。。すみませんが、朝番の方、商品Yの棚がスカスカになっているので、開店作業中に優先して品出しをお願いします。",
    restricted: false,
    user_id: 3,
    parent_id: nil,
    due_at: nil
  },
  {
    title: "扶養控除申告書の提出について",
    description: "今年も年末調整の時期がやってきました!つきましては、扶養控除申告書の提出が必要となります。書面は2Fの事務室に置いてあります。各自1部お取りいただき、期日までに提出をお願いいたします。何か不明点があれば管理者まで。",
    restricted: false,
    user_id: 1,
    parent_id: nil,
    due_at: Time.new(2026, 2, 14, 11, 0, 0, "+09:00")
  },
  {
    title: "管理者各位 期末評価について",
    description: "社長との1on1面談が実施されます。面談にあたり、今年度の自己評価表の提出が必要となります。業務システムの管理者項目、期末評価から、期日までに提出をお願いいたします。",
    restricted: true,
    user_id: 1,
    parent_id: nil,
    due_at: Time.new(2026, 2, 14, 11, 0, 0, "+09:00")
  }
]

tasks.each do |attrs|
  task = Task.find_or_create_by!(
    title: attrs[:title],
    user_id: attrs[:user_id],
    parent_id: attrs[:parent_id]
  ) do |u|
    u.assign_attributes(attrs)
  end

  if task.previously_new_record?
    puts "初期タスクを作成しました！"
    puts "#{task.title}"
    puts "説明: #{task.description}"
    puts "作成者: #{task.user.name}"
    puts "期限: #{task.due_at}"
  end
end

# タスクのステータスを日本語に変換する
def task_status_label(status)
  {
    todo: "未着手",
    in_progress: "進行中",
    done: "完了"
  }[status.to_sym]
end

# 初期のタスク割り当てを作成
task_assignments = [
  {
    task_id: 1,
    user_id: 3,
    status: :todo
  },
  {
    task_id: 2,
    user_id: 4,
    status: :todo
  },
  {
    task_id: 3,
    user_id: 2,
    status: :todo
  },
  {
    task_id: 4,
    user_id: 4,
    status: :todo
  },
  # 作成者を含めて、従業員全員に割り当てるタスク
  *User.pluck(:id).map { |uid| { task_id: 5, user_id: uid } },

  # 作成者を含めて、管理者権限を持つ全員に割り当てるタスク
  *User.where(admin: true).pluck(:id).map { |uid| { task_id: 6, user_id: uid } }
]

task_assignments.each do |attrs|
  task_assignment = TaskAssignment.find_or_create_by!(
    user_id: attrs[:user_id],
    task_id: attrs[:task_id]
  ) do |u|
    u.assign_attributes(attrs)
  end

  if task_assignment.previously_new_record?
    puts "初期のタスク割り当てを作成しました"
    puts "#{task_assignment.task.title}"
    puts "担当: #{task_assignment.user.name}"
    puts "状態: #{task_status_label(task_assignment.status)}"
  end
end
