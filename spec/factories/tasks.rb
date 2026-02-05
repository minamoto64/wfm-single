FactoryBot.define do
  factory :task do
    association :created_by_user, factory: :user

    title { "タイトル" }
    description { "説明" }
    admin_only { false }
    parent_task { nil }
    due_at { 1.week.from_now }
  end
end
