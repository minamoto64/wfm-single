FactoryBot.define do
  factory :task do
    association :user

    title { "タイトル" }
    description { "説明" }
    restricted { false }
    parent { nil }
  end
end
