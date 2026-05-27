FactoryBot.define do
  factory :notice_task do
    association :notice
    association :task
  end
end
