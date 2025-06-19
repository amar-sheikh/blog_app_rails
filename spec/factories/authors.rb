FactoryBot.define do
  factory :author do
    sequence(:name) {|n| "author#{n}" }
    sequence(:email) {|n| "author#{n}@gmail.com" }
    password { "password" }
    type { 'author' }
  end
end
