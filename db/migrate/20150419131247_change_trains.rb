class ChangeTrains < ActiveRecord::Migration
  def change
    remove_column :trains, :actual_ws, :text
  end
end
