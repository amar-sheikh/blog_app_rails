FactoryBot.define do
  factory :tag do
    sequence(:name) {|n| "tag#{n}" }
    sequence(:description) {|n| "tag#{n}-description" }
  end
end
