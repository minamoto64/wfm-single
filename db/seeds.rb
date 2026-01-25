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
