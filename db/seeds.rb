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
