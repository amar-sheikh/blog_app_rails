FactoryBot.define do
  factory :user do
    sequence(:name) {|n| "user#{n}" }
    sequence(:email) {|n| "email#{n}@gmail.com" }
    password { "password" }
  end
end
