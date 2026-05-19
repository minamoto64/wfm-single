FactoryBot.define do
  factory :notice do
    association :user

    trait :with_parent do
      association :parent, factory: :notice
    end

    sequence(:title) { |n| "タイトル#{n}" }
    content { "内容" }
    level { "important" }
    restricted { false }
    start_at { 1.hour.ago  }
    end_at { 1.week.from_now }
  end
end
