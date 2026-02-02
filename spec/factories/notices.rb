FactoryBot.define do
  factory :notice do
    association :posted_by_user, factory: :user

    title { "タイトル" }
    content { "内容" }
    notice_type { "important" }
    admin_only { false }

    start_at { 1.hour.ago  }
    end_at { 1.week.from_now }
    parent_notice { nil }
  end
end
