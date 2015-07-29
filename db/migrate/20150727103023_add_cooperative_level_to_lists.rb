class AddCooperativeLevelToLists < ActiveRecord::Migration
  def change
    add_column :lists, :public_level, :integer, :default => 0
    add_index  :lists, :public_level
  end
end
