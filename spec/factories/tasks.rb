FactoryBot.define do
  factory :task do
    association :user

    trait :with_parent do
      association :parent, factory: :task
    end

    title { "タイトル" }
    description { "説明" }
    restricted { false }
  end
end
