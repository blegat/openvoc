class CreateTrainFragments < ActiveRecord::Migration
  def change
    create_table :train_fragments do |t|
      t.integer :train_id
      t.integer :word_set_id
      t.integer :sort
      t.boolean :q_to_a           #Question to Answer ?
      t.integer :word1_id
      t.integer :word2_id
      t.string  :answer
      t.boolean :is_correct
      
      t.timestamps
    end
    
    change_table :trains do |t|
      t.text :fragments_list
      t.integer :fragment_pos
    end
  end
end
