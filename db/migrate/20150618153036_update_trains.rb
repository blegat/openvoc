class UpdateTrains < ActiveRecord::Migration
  def change
    change_table :trains do |t|
      t.integer :type_of_train
      t.integer :ask_policy
      t.boolean :include_sub_lists
    end
  end
end
