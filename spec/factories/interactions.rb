FactoryBot.define do
  factory :interaction do
    customer { nil }
    user { nil }
    interaction_date { "2026-01-30 19:12:08" }
    interaction_type { "MyString" }
    content { "MyText" }
    result { "MyText" }
    is_completed { false }
    parent_interaction { nil }
  end
end
