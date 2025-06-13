class Article < ApplicationRecord
  belongs_to :author, class_name: 'Author'
  has_many :comments
  has_and_belongs_to_many :tags
end
