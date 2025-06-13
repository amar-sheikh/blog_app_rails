FactoryBot.define do
  factory :author do
    sequence(:name) {|n| "author#{n}" }
    sequence(:bio) {|n| "author#{n}-bio" }
    user { nil }
  end
end
