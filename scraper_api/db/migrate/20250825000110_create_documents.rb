class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :website, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end


