FactoryBot.define do
  factory :comment do
    sequence(:content) {|n| "comment#{n}" }
    user { nil }
    article { nil }
  end
end
