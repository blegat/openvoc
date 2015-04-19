class AddTrainsInfoToWordSets < ActiveRecord::Migration
  def change
    change_table :word_sets do |t|
      t.integer :asked
      t.integer :success
      t.float   :success_ratio
    end
        
    remove_column :trains, :word_id, :integer
    remove_column :trains, :guess, :string
    remove_column :trains, :success, :boolean
    
    
    change_table :trains do |t|
      t.integer :list_id
      t.boolean :finished
      t.float   :success_ratio
      t.text    :word_sets_ids
      t.integer :actual_ws_id
      t.text    :word_sets_ids_failed
      t.text    :word_sets_ids_succeeded
      t.integer :max
    end
    
    add_index :trains, :list_id
  end
end
