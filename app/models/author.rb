class Author < User
  has_many :articles, foreign_key: :author_id
end
