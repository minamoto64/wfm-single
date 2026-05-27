FactoryBot.define do
  factory :interaction_task do
    association :interaction
    association :task
  end
end
