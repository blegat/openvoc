class UpdateProContra < ActiveRecord::Migration
  def change
    remove_column :meanings, :pro, :integer
    remove_column :meanings, :contra, :integer
    remove_column :meanings, :confidence, :float
    add_column :links, :pro, :integer, default: 0
    add_column :links, :contra, :integer, default: 0

  end
end
