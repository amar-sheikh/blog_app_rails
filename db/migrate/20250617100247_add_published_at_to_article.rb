class AddPublishedAtToArticle < ActiveRecord::Migration[7.2]
  def change
    add_column :articles, :published_at, :datetime
  end
end
