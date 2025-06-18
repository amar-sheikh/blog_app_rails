FactoryBot.define do
  factory :comment do
    association :user
    sequence(:content) {|n| "comment#{n}" }
    article { nil }
  end
end
