FactoryBot.define do
  factory :task do
    association :user

    trait :with_parent do
      association :parent, factory: :task
    end

    sequence(:title) { |n| "タイトル#{n}" }
    description { "説明" }
    restricted { false }
    due_at { 1.week.from_now }
  end
end
