class CreateWebsites < ActiveRecord::Migration[8.0]
  def change
    create_table :websites do |t|
      t.string :url, null: false
      t.datetime :scraped_at

      t.timestamps
    end

    add_index :websites, :url, unique: true
  end
end


