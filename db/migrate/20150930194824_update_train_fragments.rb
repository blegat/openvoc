class UpdateTrainFragments < ActiveRecord::Migration
  def change
    rename_column :train_fragments, :word1_id, :item1_id
    rename_column :train_fragments, :word2_id, :item2_id
    add_column :train_fragments, :item1_is_word, :boolean
    add_column :train_fragments, :item2_is_word, :boolean
    add_column :train_fragments, :language1_id, :integer
    add_column :train_fragments, :language2_id, :integer
  end
end
