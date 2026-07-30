# ==============================================================================
# デモ環境専用シード
# ------------------------------------------------------------------------------
# ここで作成する全レコードは demo: true で保存される。
# 本番の見せ場データ（db/seeds.rb）とは完全に独立しており、
# `bin/rails demo:reset` によって定期的に全削除→再投入される想定。
# ==============================================================================

Current.demo = true
rng = Random.new(20260729)

# 実行した時刻に関わらず、営業時間内(9〜18時台)のそれらしい時刻にする
def business_hour(time, rng)
  time.change(hour: rng.rand(9..18), min: [ 0, 15, 30, 45 ].sample(random: rng))
end

# ==============================================================================
# デモ用チームメンバー
# ==============================================================================
demo_users_data = [
  { key: :admin,   name: "高橋 誠",   email_address: User::DEMO_LOGIN_EMAIL,    admin: true  },
  { key: :manager, name: "中村 由美", email_address: "demo.manager@example.com", admin: true  },
  { key: :staff1,  name: "小林 大輔", email_address: "demo.staff1@example.com",  admin: false },
  { key: :staff2,  name: "渡辺 さくら", email_address: "demo.staff2@example.com", admin: false },
  { key: :staff3,  name: "加藤 翔太", email_address: "demo.staff3@example.com", admin: false }
]

demo_users = {}

demo_users_data.each do |attrs|
  demo_users[attrs[:key]] = User.create!(
    name: attrs[:name],
    email_address: attrs[:email_address],
    password: SecureRandom.hex(16),
    admin: attrs[:admin],
    demo: true
  )
end

all_demo_users = demo_users.values
demo_admin   = demo_users[:admin]
demo_manager = demo_users[:manager]

puts "デモ用チームメンバー #{all_demo_users.size}件を作成しました"

# ==============================================================================
# デモ用顧客
# ==============================================================================
customers_data = [
  { name: "鈴木 一郎",     email: "suzuki.demo@example.com", phone: "090-1111-2222", key_notes: "法人契約あり。担当は高橋。" },
  { name: "田中 美咲",     email: "tanaka.demo@example.com", phone: "080-2222-3333", key_notes: "メール連絡希望。電話は不可の時間帯あり。" },
  { name: "伊藤 健太",     email: "",                        phone: "090-3333-4444", key_notes: "" },
  { name: "渡辺 直子",     email: "watanabe.demo@example.com", phone: "",             key_notes: "常連。年に数回まとめ買いあり。" },
  { name: "山本 隆",       email: "",                        phone: "070-4444-5555", key_notes: "英語対応が必要な場合あり。" },
  { name: "中島 陽子",     email: "nakajima.demo@example.com", phone: "090-5555-6666", key_notes: "" },
  { name: "小川 誠一",     email: "",                        phone: "080-6666-7777", key_notes: "クレーム対応中の案件あり。" },
  { name: "石井 千夏",     email: "ishii.demo@example.com",  phone: "090-7777-8888", key_notes: "" },
  { name: "森田 亮",       email: "",                        phone: "",              key_notes: "家族経由での連絡が多い。" },
  { name: "新井 美穂",     email: "arai.demo@example.com",   phone: "070-8888-9999", key_notes: "初回問い合わせのみ。" },
  { name: "青木 大地",     email: "",                        phone: "090-9999-0000", key_notes: "" },
  { name: "藤田 沙織",     email: "fujita.demo@example.com", phone: "080-0000-1111", key_notes: "リピーター。対応は丁寧に。" },
  { name: "松本 和也",     email: "",                        phone: "090-1212-3434", key_notes: "" },
  { name: "西村 留美",     email: "nishimura.demo@example.com", phone: "",             key_notes: "" },
  { name: "岡田 亮太",     email: "",                        phone: "080-5656-7878", key_notes: "支払い方法についての問い合わせ多い。" },
  { name: "長谷川 香織",   email: "hasegawa.demo@example.com", phone: "090-3456-7890", key_notes: "" },
  { name: "村上 拓海",     email: "",                        phone: "",              key_notes: "取り寄せ品を注文中。" },
  { name: "近藤 恵",       email: "kondo.demo@example.com",  phone: "070-2345-6789", key_notes: "" }
]

demo_customers = customers_data.map do |attrs|
  Customer.create!(
    name: attrs[:name],
    email: attrs[:email],
    phone: attrs[:phone],
    key_notes: attrs[:key_notes],
    demo: true
  )
end

puts "デモ用顧客 #{demo_customers.size}件を作成しました"

# ==============================================================================
# 応対履歴（顧客ごとに1〜3件、一部はスレッド化）
# ==============================================================================
products = [
  "ポータブル電源 PW-500", "ロボット掃除機 RC-200", "空気清浄機 AP-100", "電気ケトル EK-800",
  "食器洗い乾燥機用フィルター", "エアコン室外機カバー", "コードレス掃除機 CL-300", "加湿器 HM-150"
]

issue_templates = [
  {
    request: ->(product) { "#{product}の在庫状況について問い合わせ。入荷したら連絡してほしいとのこと。" },
    response: ->(product) { "在庫を確認したところ次回入荷は来週の見込みと回答。入荷次第連絡する旨を伝えた。" },
    follow_request: "入荷連絡の電話をするも不在のため、留守電にメッセージを残した。",
    follow_response: "翌日、本人より折り返しあり。取り置きを希望されたため、店舗にて確保した。"
  },
  {
    request: ->(product) { "#{product}の動作不良について相談。電源が入らないとのこと。" },
    response: ->(product) { "リモートで簡単な切り分けを実施。改善しない場合は店頭持ち込みをご案内した。" },
    follow_request: "店頭に持ち込みいただき、実機を確認。初期不良の可能性が高いと判断。",
    follow_response: "メーカーへの交換手配を実施。1週間程度で代替品が届く見込みと案内した。"
  },
  {
    request: ->(product) { "#{product}の使い方について質問。取扱説明書が見当たらないとのこと。" },
    response: ->(product) { "取扱説明書のPDFをメールで送付し、主要な使い方を口頭でも説明した。" },
    follow_request: nil,
    follow_response: nil
  },
  {
    request: ->(product) { "#{product}の追加購入を検討しており、他モデルとの違いについて質問。" },
    response: ->(product) { "上位モデルとの機能差を説明。予算に応じて#{product}を再度おすすめした。" },
    follow_request: "後日、追加購入の連絡あり。配送日時の希望を確認。",
    follow_response: "希望日時で配送手配を完了。到着予定日を案内した。"
  },
  {
    request: ->(product) { "#{product}の返品を希望。イメージと違ったとのこと。" },
    response: ->(product) { "返品ポリシーを説明し、未使用であれば対応可能と回答。店舗への持参をお願いした。" },
    follow_request: nil,
    follow_response: nil
  },
  {
    request: ->(product) { "#{product}の保証期間について確認したいとのこと。" },
    response: ->(product) { "購入日を確認し、保証書記載の期間内であることを案内。修理受付の流れも説明した。" },
    follow_request: nil,
    follow_response: nil
  }
]

channels = %i[phone email web sns in_person]

demo_customers.each_with_index do |customer, index|
  template = issue_templates[index % issue_templates.size]
  product  = products[rng.rand(products.size)]
  staff    = all_demo_users[rng.rand(all_demo_users.size)]
  occurred = business_hour(rng.rand(2..45).days.ago, rng)

  parent = Interaction.create!(
    customer: customer,
    user: staff,
    occurred_at: occurred,
    channel: channels[rng.rand(channels.size)],
    request_content: template[:request].call(product),
    response_result: template[:response].call(product),
    completed: template[:follow_request].nil? ? [ true, false ].sample(random: rng) : false,
    demo: true
  )

  next unless template[:follow_request]

  follow_staff = all_demo_users[rng.rand(all_demo_users.size)]
  Interaction.create!(
    parent: parent,
    user: follow_staff,
    occurred_at: occurred + rng.rand(1..5).days,
    channel: channels[rng.rand(channels.size)],
    request_content: template[:follow_request],
    response_result: template[:follow_response],
    completed: true,
    demo: true
  )
end

puts "デモ用応対履歴を作成しました（顧客あたり1〜2件、一部スレッド化）"

# ==============================================================================
# 周知事項
# ==============================================================================
notices_data = [
  {
    key: :product_recall,
    title: "ポータブル電源 PW-500 一部ロットの注意喚起",
    content: "対象ロット(2025年10月〜12月製造分)において、まれに充電中の発熱事例が報告されています。該当のお問い合わせがあった場合は、型番シールの製造ロットを必ず確認し、対象であれば使用中止と点検をご案内してください。詳細な手順はマニュアルP.22を参照してください。",
    level: :important, restricted: false, user_key: :admin, parent_key: nil
  },
  {
    key: :recall_followup,
    title: "PW-500注意喚起の対応状況共有",
    content: "各店舗からの一次対応状況を集約しました。現時点で発熱の申出は3件、いずれも初期対応で完了しています。引き続き該当ロットのお問い合わせには注意して対応をお願いします。",
    level: :normal, restricted: false, user_key: :manager, parent_key: :product_recall
  },
  {
    key: :register_shortage,
    title: "レジ釣銭準備について",
    content: "月末に釣銭不足が発生する店舗が続いています。閉店時の釣銭準備チェックリストを必ず実施し、不足が見込まれる場合は前日までに本部へ連絡してください。",
    level: :normal, restricted: false, user_key: :admin, parent_key: nil
  },
  {
    key: :new_pos_training,
    title: "新POSレジ操作研修のお知らせ",
    content: "来月導入予定の新POSレジについて、操作研修を実施します。対象者はシフト管理担当より別途案内しますので、必ず参加してください。",
    level: :normal, restricted: false, user_key: :manager, parent_key: nil
  },
  {
    key: :staff_leave_consult,
    title: "スタッフの勤務相談について",
    content: "渡辺さんより、家庭の事情によりしばらく勤務時間を短縮したいと相談がありました。来月のシフトから調整予定です。周囲のフォローをお願いします。",
    level: :important, restricted: true, user_key: :manager, parent_key: nil
  },
  {
    key: :staff_leave_resolved,
    title: "勤務相談の調整完了について",
    content: "渡辺さんの勤務時間短縮について、来月分のシフト調整が完了しました。ご協力ありがとうございました。何か困りごとがあれば引き続き相談に乗ってあげてください。",
    level: :normal, restricted: true, user_key: :manager, parent_key: :staff_leave_consult
  },
  {
    key: :seasonal_campaign,
    title: "季節キャンペーンの開始について",
    content: "来週より季節限定キャンペーンを開始します。対象商品にはPOPを設置し、レジでの声かけを徹底してください。詳細は別紙販促資料を確認してください。",
    level: :normal, restricted: false, user_key: :admin, parent_key: nil
  },
  {
    key: :complaint_trend,
    title: "配送遅延に関するクレーム増加について",
    content: "配送業者側の都合により、一部エリアで配送遅延が発生しています。該当のお問い合わせには状況を丁寧に説明し、必要に応じて代替案内を行ってください。",
    level: :important, restricted: false, user_key: :admin, parent_key: nil
  },
  {
    key: :inventory_check,
    title: "月次棚卸のスケジュールについて",
    content: "来月の棚卸日程が確定しました。各担当エリアの割り当てはシフト表を確認してください。棚卸差異が大きい場合は速やかに報告をお願いします。",
    level: :normal, restricted: false, user_key: :manager, parent_key: nil
  },
  {
    key: :admin_eval,
    title: "管理者各位 半期評価について",
    content: "半期評価の提出期限が近づいています。自己評価シートは共有フォルダから取得し、期日までに提出してください。",
    level: :important, restricted: true, user_key: :admin, parent_key: nil
  },
  {
    key: :safety_check,
    title: "店舗設備の安全点検について",
    content: "消防設備の定期点検を来週実施します。点検員が訪問しますので、対象エリアへの立ち入りにご協力ください。",
    level: :normal, restricted: false, user_key: :admin, parent_key: nil
  },
  {
    key: :customer_survey,
    title: "顧客満足度アンケートのご協力依頼",
    content: "本部にて顧客満足度アンケートを実施します。ご来店のお客様にご案内カードをお渡しし、回答のご協力をお願いしてください。",
    level: :normal, restricted: false, user_key: :manager, parent_key: nil
  }
]

demo_notices = {}

notices_data.each do |attrs|
  parent = attrs[:parent_key] ? demo_notices[attrs[:parent_key]] : nil

  demo_notices[attrs[:key]] = Notice.create!(
    title: attrs[:title],
    content: attrs[:content],
    level: attrs[:level],
    restricted: attrs[:restricted],
    start_at: business_hour(rng.rand(1..10).days.ago, rng),
    end_at: business_hour(rng.rand(30..90).days.from_now, rng),
    user: demo_users[attrs[:user_key]],
    parent: parent,
    demo: true
  )
end

puts "デモ用周知事項 #{demo_notices.size}件を作成しました"

# ==============================================================================
# タスク
# ==============================================================================
tasks_data = [
  { key: :recall_inspection, title: "PW-500対象ロットの店頭在庫確認", description: "注意喚起のあったロットについて、店頭在庫の型番シールを全数確認し、該当品を隔離する。", restricted: false, user_key: :admin, parent_key: nil, due_in_days: 3 },
  { key: :recall_report,     title: "在庫確認結果の本部報告",       description: "店頭在庫確認の結果を本部指定のフォーマットでまとめ、期日までに報告する。", restricted: false, user_key: :staff1, parent_key: :recall_inspection, due_in_days: 5 },
  { key: :pos_training_prep, title: "新POSレジ研修の会場準備",       description: "研修当日に使用する会場のレイアウトと機材の手配を行う。", restricted: false, user_key: :manager, parent_key: nil, due_in_days: 10 },
  { key: :pos_training_material, title: "新POSレジ研修資料の作成", description: "操作マニュアルを基に、研修用の実践資料を作成する。誤操作しやすい箇所は特に丁寧に解説を入れる。", restricted: false, user_key: :staff2, parent_key: :pos_training_prep, due_in_days: 8 },
  { key: :campaign_pop,      title: "季節キャンペーンPOPの設置",     description: "対象商品の陳列棚にキャンペーンPOPを設置する。設置後は写真を撮って共有フォルダにアップロードする。", restricted: false, user_key: :staff3, parent_key: nil, due_in_days: 2 },
  { key: :campaign_review,   title: "キャンペーン開始後の売上確認",   description: "キャンペーン開始1週間後の売上動向を確認し、簡単なレポートを作成する。", restricted: false, user_key: :manager, parent_key: :campaign_pop, due_in_days: 9 },
  { key: :delivery_followup, title: "配送遅延クレーム対応状況の集約", description: "各店舗からの配送遅延に関する問い合わせ件数と対応状況を集約する。", restricted: false, user_key: :admin, parent_key: nil, due_in_days: 4 },
  { key: :inventory_prep,    title: "棚卸準備リストの確認",         description: "棚卸当日までに必要な備品と担当エリアの割り当てを確認し、不足があれば発注する。", restricted: false, user_key: :staff1, parent_key: nil, due_in_days: 12 },
  { key: :inventory_report,  title: "棚卸差異の一次報告",           description: "棚卸実施後、差異が大きかった品目について一次報告をまとめる。", restricted: false, user_key: :staff2, parent_key: :inventory_prep, due_in_days: 15 },
  { key: :admin_eval_submit, title: "半期自己評価シートの提出",       description: "自己評価シートに記入し、期日までに提出する。", restricted: true, user_key: :admin, parent_key: nil, due_in_days: 6 },
  { key: :safety_check_prep, title: "消防設備点検の立ち会い準備",     description: "点検員の訪問エリアを事前に片付け、立ち会い担当を決めておく。", restricted: false, user_key: :staff3, parent_key: nil, due_in_days: 5 },
  { key: :survey_cards,      title: "顧客アンケートカードの補充",     description: "レジ横のアンケートカードが不足しないよう、在庫を確認し補充する。", restricted: false, user_key: :staff1, parent_key: nil, due_in_days: 3 },
  { key: :staff_shift_adjust, title: "スタッフのシフト調整対応",      description: "勤務時間短縮の相談を受けたスタッフのシフトを来月分から調整する。", restricted: true, user_key: :manager, parent_key: nil, due_in_days: 7 },
  { key: :warranty_process,  title: "初期不良品の交換手配",         description: "店頭持ち込みのあった初期不良品について、メーカーへ交換手配を依頼する。", restricted: false, user_key: :staff2, parent_key: nil, due_in_days: 4 },
  { key: :new_product_check, title: "新商品陳列の最終チェック",       description: "来月発売予定の新商品について、陳列位置と価格表示に誤りがないか最終確認する。", restricted: false, user_key: :staff3, parent_key: nil, due_in_days: nil },
  { key: :everyone_reminder, title: "年末調整書類の提出について",     description: "扶養控除等申告書の提出が必要です。書式は事務室に用意してあるので、期日までに1部ずつ提出してください。", restricted: false, user_key: :admin, parent_key: nil, due_in_days: 14 },
  { key: :cleaning_rotation, title: "店内清掃当番の見直し",         description: "清掃当番表を見直し、繁忙時間帯を避けたローテーションに変更する。", restricted: false, user_key: :manager, parent_key: nil, due_in_days: 6 },
  { key: :complaint_manual_update, title: "クレーム対応マニュアルの更新", description: "最近の対応事例を踏まえ、クレーム対応マニュアルに補足事項を追記する。", restricted: true, user_key: :admin, parent_key: nil, due_in_days: 10 }
]

demo_tasks = {}

tasks_data.each do |attrs|
  parent = attrs[:parent_key] ? demo_tasks[attrs[:parent_key]] : nil

  demo_tasks[attrs[:key]] = Task.create!(
    title: attrs[:title],
    description: attrs[:description],
    restricted: attrs[:restricted],
    user: demo_users[attrs[:user_key]],
    parent: parent,
    due_at: attrs[:due_in_days] ? business_hour(attrs[:due_in_days].days.from_now, rng) : nil,
    demo: true
  )
end

puts "デモ用タスク #{demo_tasks.size}件を作成しました"

# タスク担当割り当て（作成者 + ランダムに1〜2名を追加）
statuses = %i[todo in_progress done]

demo_tasks.each_value do |task|
  assignees = [ task.user ]
  assignees += all_demo_users.reject { |u| u == task.user }.sample(rng.rand(1..2), random: rng)

  assignees.uniq.each do |user|
    TaskAssignment.create!(
      task: task,
      user: user,
      status: statuses[rng.rand(statuses.size)],
      demo: true
    )
  end
end

puts "デモ用タスク割り当てを作成しました"

# ==============================================================================
# タスクと周知事項・応対履歴の関連付け（一部のみ）
# ==============================================================================
NoticeTask.create!(notice: demo_notices[:product_recall], task: demo_tasks[:recall_inspection])
NoticeTask.create!(notice: demo_notices[:new_pos_training], task: demo_tasks[:pos_training_prep])
NoticeTask.create!(notice: demo_notices[:seasonal_campaign], task: demo_tasks[:campaign_pop])
NoticeTask.create!(notice: demo_notices[:inventory_check], task: demo_tasks[:inventory_prep])

puts "デモ用の周知事項⇔タスク関連付けを作成しました"

# 応対履歴も、一部をタスク・周知事項に「展開」した形にする
demo_interactions = Interaction.where(demo: true).to_a

demo_interactions.sample(8, random: rng).each do |interaction|
  InteractionTask.create!(interaction: interaction, task: demo_tasks.values.sample(random: rng))
end

demo_interactions.sample(6, random: rng).each do |interaction|
  InteractionNotice.create!(interaction: interaction, notice: demo_notices.values.sample(random: rng))
end

puts "デモ用の応対履歴⇔タスク／周知事項の関連付けを作成しました"

# ==============================================================================
# コメント
# ==============================================================================
comment_pool = [
  "対応ありがとうございます、引き続きよろしくお願いします。",
  "念のため写真も共有フォルダに追加しておきました。",
  "こちらの件、進捗があれば教えてください。",
  "確認しました。次のアクションを進めます。",
  "類似の問い合わせが他店舗でもあったようです。",
  "期日に間に合いそうか、早めに共有お願いします。",
  "承知しました、対応します。"
]

commentable_pools = demo_tasks.values + demo_notices.values + Interaction.where(demo: true).to_a

18.times do
  target  = commentable_pools.sample(random: rng)
  author  = all_demo_users[rng.rand(all_demo_users.size)]

  Comment.create!(
    commentable: target,
    user: author,
    content: comment_pool[rng.rand(comment_pool.size)],
    demo: true
  )
end

puts "デモ用コメントを作成しました"

Current.demo = false

puts "=================================================="
puts "デモ用シードデータの投入が完了しました"
puts "=================================================="
