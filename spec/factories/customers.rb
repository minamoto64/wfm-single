FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "テスト顧客#{n}" }
    sequence(:email) { |n| "tanaka#{n}@example.com" }
    sequence(:phone) { |n| format("090-1234-%04d", n % 10000) }
    key_notes { "常連さん" }
  end
end
