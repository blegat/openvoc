class AddOwnerToWordsAndLinks < ActiveRecord::Migration
  def change
    change_table :words do |t|
      t.references :owner
    end
    change_table :links do |t|
      t.references :owner
    end
  end
end
