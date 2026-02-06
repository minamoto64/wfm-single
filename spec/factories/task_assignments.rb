FactoryBot.define do
  factory :task_assignment do
    association :task
    association :user
    status { "in_progress" }
  end
end
