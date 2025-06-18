# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

require 'faker'

Comment.delete_all
Article.delete_all
Tag.delete_all
User.delete_all

users = 25.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    type: nil
  )
end

authors = 25.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: 'password',
    type: 'Author'
  )
end

tags = 20.times.map do
  Tag.create!(
    name: Faker::Lorem.unique.word,
    description: Faker::Lorem.sentence
  )
end

articles = 200.times.map do
  published  = [true, false].sample

  Article.create!(
    title: Faker::Book.title,
    content: Faker::Lorem.paragraphs(number: 5).join("\n"),
    published: published,
    author_id: authors.sample.id,
    published_at: published ? Time.at(rand(30.days.ago.to_f..2.hours.ago.to_f)) : nil
  )
end

articles.each do |article|
  article.tags << tags.sample(rand(1..4))
end

comments = 500.times.map do
  Comment.create!(
    content: Faker::Lorem.sentence,
    user_id: users.sample.id,
    article_id: articles.sample.id
  )
end
