FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "テストユーザー#{n}" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { Faker::Internet.password(min_length: 8) }
  end
end
