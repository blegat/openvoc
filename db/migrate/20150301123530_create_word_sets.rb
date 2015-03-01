class CreateWordSets < ActiveRecord::Migration
  def change
    create_table :word_sets do |t|
      t.integer :word1_id
      t.integer :word2_id
      t.integer :meaning1_id
      t.integer :meaning2_id
      t.references :user, index: true
      t.references :list, index: true

      t.timestamps
    end
    
    change_table :lists do|t|
      t.integer :language1_id
      t.integer :language2_id
    end
        
  end
end
