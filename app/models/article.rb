class Article < ApplicationRecord
  belongs_to :author, class_name: 'Author'
  has_many :comments
  has_and_belongs_to_many :tags

  scope :published, -> { where(published: true) }
  scope :un_published, -> { where(published: false) }
  scope :recent, ->(day_count = 7) { published.where('published_at >= ?', day_count.days.ago) }
  scope :search, ->(text) { where('LOWER(articles.title) LIKE :query OR LOWER(articles.content) LIKE :query', query: "%#{text.downcase}%") }
  scope :by_authors, ->(author_ids) { where(author_id: author_ids.compact) }

  scope :tagged, ->(tag_ids = []) do
    tagged = joins(:tags).distinct
    tag_ids.present? ? tagged.where(tags: { id: tag_ids.compact }) : tagged
  end

  scope :commented, ->(count = 1) do
    published
      .joins(:comments)
      .select('articles.*, COUNT(DISTINCT comments.id) AS comments_count')
      .group('articles.id')
      .having('COUNT(DISTINCT comments.id) >= ?', count)
  end

  scope :hot, -> (day_count = 7, tag_ids = []) do
    recent(day_count)
      .tagged(tag_ids)
      .commented()
      .select("TRUE AS hot")
      .distinct()
  end

  scope :trending, -> (comments_count = 5, day_count = 3, tag_ids = []) do
    hot(day_count, tag_ids)
      .commented(comments_count)
      .select("TRUE AS trending")
      .order('comments_count DESC, published_at DESC')
      .limit(5)
  end
end
