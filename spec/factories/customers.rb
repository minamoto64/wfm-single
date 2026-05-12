FactoryBot.define do
  factory :customer do
    name { "田中健人" }
    email { "tanaka@example.com" }
    phone { "090-1234-5678" }
    key_notes { "常連さん" }
  end
end
