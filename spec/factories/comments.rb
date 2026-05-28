FactoryBot.define do
  factory :comment do
    association :user
    content { Faker::Lorem.sentence }

    trait :on_interaction do
      association :commentable, factory: :interaction
    end

    trait :on_task do
      association :commentable, factory: :task
    end

    trait :on_notice do
      association :commentable, factory: :notice
    end
  end
end
