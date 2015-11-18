class ChangeTrains < ActiveRecord::Migration
  def change
    remove_column :trains, :actual_ws_id, :text
  end
end
