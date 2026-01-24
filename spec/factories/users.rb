FactoryBot.define do
  factory :user do
    name { "鈴木一郎" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password55" }
  end
end
