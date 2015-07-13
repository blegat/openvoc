class UpdateTrainsAndWordSets < ActiveRecord::Migration
  def up
      remove_column :trains, :word_sets_ids
      remove_column :trains, :actual_ws_id
      remove_column :trains, :word_sets_ids_failed
      remove_column :trains, :word_sets_ids_succeeded
      add_column    :trains, :q_to_a, :integer
      add_column    :trains, :finalized, :boolean
      rename_column :trains, :ask_policy, :error_policy
      
      rename_column :word_sets, :asked, :asked_qa
      rename_column :word_sets, :success, :success_qa
      rename_column :word_sets, :success_ratio, :success_ratio_qa
      add_column    :word_sets, :asked_aq, :float
      add_column    :word_sets, :success_aq, :float
      add_column    :word_sets, :success_ratio_aq, :float
      
  end
  
  
  def down
    add_column :trains, :word_sets_ids, :text
    add_column :trains, :actual_ws_id, :text
    add_column :trains, :word_sets_ids_failed, :text
    add_column :trains, :word_sets_ids_succeeded, :text
    remove_column :trains, :q_to_a
    remove_column :trains, :finalized
    rename_column :trains, :error_policy, :ask_policy  
    
    rename_column :word_sets, :asked_qa, :asked
    rename_column :word_sets, :success_qa, :success
    rename_column :word_sets, :success_ratio_qa, :success_ratio
    delete_column :word_sets, :asked_aq
    delete_column :word_sets, :success_aq
    delete_column :word_sets, :success_ratio_aq
  end
  

  

end
