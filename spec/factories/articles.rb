FactoryBot.define do
  factory :article do
    sequence(:title) {|n| "article#{n}" }
    sequence(:bio) {|n| "article#{n}-content" }
    published { false }
    author { nil }
  end
end
