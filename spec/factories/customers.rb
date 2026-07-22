FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "テスト顧客#{n}" }
    email { "tanaka@example.com" }
    phone { "090-1234-5678" }
    key_notes { "常連さん" }
  end
end
