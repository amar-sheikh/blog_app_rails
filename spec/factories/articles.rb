FactoryBot.define do
  factory :article do
    association :author

    sequence(:title) {|n| "article#{n}" }
    sequence(:content) {|n| "article#{n}-content" }
    published { false }
    published_at { nil }

    trait :commented do
      published { true }
      published_at { 7.days.ago }

      transient do
        comments_count { 1 }
      end

      after(:create) do |article, evaluator|
        create_list(:comment, evaluator.comments_count, article: article)
      end
    end
  end
end
