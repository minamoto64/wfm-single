FactoryBot.define do
  factory :interaction do
    association :customer
    association :user

    occurred_at { Time.current }
    channel { "phone" }
    request_content { "問い合わせ内容" }
    response_result { "対応結果" }
    completed { false }

    trait :with_parent do
      parent { association :interaction, customer: customer }
    end
  end
end
