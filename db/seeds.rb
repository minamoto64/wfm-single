# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 管理者ユーザー
admin = User.create!(
  name: "管理者",
  email_address: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  admin: true
)

#一般ユーザー
user = User.create!(
  name: "山田太郎",
  email_address: "yamada@example.com",
  password: "password",
  password_confirmation: "password",
  admin: false
)

puts "初期ユーザーを作成しました！"
puts "管理者: #{admin.email_address} / password"
puts "従業員: #{user.email_address} / password"
