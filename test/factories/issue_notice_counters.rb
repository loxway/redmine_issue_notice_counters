FactoryBot.define do

  factory :issue_notice_counters do
    sequence(:name) { |n| "name-#{n}"}
    association :author, factory: :user
    project
  end

end
