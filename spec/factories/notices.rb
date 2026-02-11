FactoryBot.define do
  factory :notice do
    association :user

    title { "タイトル" }
    content { "内容" }
    level { "important" }
    parent { nil }
    restricted { false }
    start_at { 1.hour.ago  }
    end_at { 1.week.from_now }
  end
end
