FactoryBot.define do
  factory :interaction_notice do
    association :interaction
    association :notice
  end
end
