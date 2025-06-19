class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.boolean :published
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
