class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :word1
      t.references :word2

      t.timestamps
    end
    add_index :links, :word1_id
    add_index :links, :word2_id

    change_table :words do |t|
      t.references :link
    end
  end
end
